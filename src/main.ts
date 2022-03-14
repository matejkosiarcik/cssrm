import { execa } from 'execa';
import * as fs from 'fs/promises';
import * as fsSync from 'fs';
import path from 'path';
import hasha from 'hasha';
import * as os from 'os';
import yargs from 'yargs';
import { hideBin } from 'yargs/helpers';
import { fileURLToPath } from 'url';

let verbose = false;

async function getVersion(): Promise<string> {
  let filePath = '';
  try {
    filePath = __filename;
  } catch {
    filePath = fileURLToPath(import.meta.url);
  }
  const projectPath = path.dirname(path.dirname(path.resolve(filePath)));
  const packagePath = path.join(projectPath, 'package.json');
  try {
    const packageContent = await fs.readFile(packagePath, 'utf-8');
    const { version } = JSON.parse(packageContent);
    if (version) {
      return version;
    }
  } catch (error) {
    console.error(error);
  }
  return 'N/A';
}

const minifiers = [
  {
    name: 'cleancss',
    command: ['cleancss', '-O2', '$INPUT$', '--output', '$OUTPUT$'],
  },
  {
    name: 'cssnano',
    command: ['cssnano', '$INPUT$', '$OUTPUT$'],
  },
  {
    name: 'csso',
    command: ['csso', '--comments', 'none', '--force-media-merge', '--input', '$INPUT$', '--output', '$OUTPUT$'],
  },
  {
    name: 'crass',
    command: ['crass', '$INPUT$', '--css4'],
  },
];

/**
 * Just get filesize in bytes
 */
async function getSize(file: string): Promise<number> {
  const stats = await fs.stat(file);
  return stats.size;
}

/**
 * Just get a hash of file content
 */
async function getHash(file: string): Promise<string> {
  const hashBase16 = await hasha.fromFile(file, { algorithm: 'sha256' });
  const hashBase36 = BigInt(`0x${hashBase16}`).toString(36); // base36 represents numbers [0-9] and letters [a-z]
  return hashBase36.substr(0, 6);
}

/**
 * Run all minifiers on a single input file
 */
async function optimizeFileSingleStage(inputPath: string, workDir: string): Promise<Array<string>> {
  const inputName = path.basename(inputPath).replace(/\.css$/, '');

  return Promise.all(minifiers.map(async (minifier) => {
    const outputPath = path.join(workDir, `${inputName}-${minifier.name}.css`);

    const [readFile, writeFile] = await Promise.all([
      fs.open(inputPath, 'r'),
      fs.open(outputPath, 'w'),
    ]);
    const realCommand = minifier.command.map((word) => {
      if (word === '$INPUT$') {
        return inputPath;
      }
      if (word === '$OUTPUT$') {
        return outputPath;
      }
      return word;
    });
    await execa(realCommand[0], realCommand.slice(1), { stdin: readFile.fd, stdout: writeFile.fd });

    await Promise.all([
      readFile.close(),
      writeFile.close(),
    ]);
    return outputPath;
  }));
}

/**
 * Optimize given file
 * input >> optimize >> output
 */
async function optimizeFile(input: string) {
  const tmpdir = await fs.mkdtemp(path.join(os.tmpdir(), 'cmmm_'));

  // determine filepath to read
  const inputPath = (input === '-' ? path.join(tmpdir, 'stdin.css') : input);
  if (input === '-') { // pre-read stdin into file for further processing
    try {
      const stdinContent = fsSync.readFileSync(process.stdin.fd, 'utf-8');
      await fs.writeFile(inputPath, stdinContent, 'utf-8');
    } catch (error) {
      console.error(`Could not read stdin (${error})`);
      process.exit(1);
    }
  }

  if (verbose) {
    console.error(`${path.basename(inputPath)}: ${await getSize(inputPath)}`);
    console.error();
  }

  // basically optimize till we can
  // when we stop getting any gains, we stop
  let bestFilePath = inputPath;
  /* eslint-disable no-await-in-loop */
  for (let i = 0; i < 10; i += 1) {
    const stageDir = await fs.mkdtemp(tmpdir);
    const stageOutputPaths = await optimizeFileSingleStage(bestFilePath, stageDir);

    const stageOutputs = (await Promise.all(stageOutputPaths.map(async (file) => ({
      file: file,
      hash: await getHash(file),
      size: await getSize(file),
    })))).sort((a, b) => a.size - b.size);

    if (verbose) {
      stageOutputs.forEach((fileData) => {
        console.error(`${path.basename(fileData.file)}: ${fileData.size} (${fileData.hash})`);
      });
      console.error();
    }

    if (stageOutputs[0].size >= await getSize(bestFilePath)) {
      break;
    }

    bestFilePath = stageOutputs[0].file;
  }
  /* eslint-enable no-await-in-loop */

  await fs.copyFile(bestFilePath, input);
  await fs.rm(tmpdir, { recursive: true, force: true });
}

async function readDirectory(directory: string): Promise<string[]> {
  const files = (await fs.readdir(directory)).map((file) => path.join(directory, file));

  const output = await Promise.all(files.map(async (file) => {
    const stats = await fs.stat(file);
    if (stats.isDirectory()) {
      return readDirectory(file);
    }
    if (/\.css$/.test(file)) {
      return [file];
    }
    return [];
  }));
  return output.flat();
}

async function optimizeFiles(files: string[]) {
  files.forEach((file) => {
    if (!fsSync.existsSync(file)) {
      console.error(`File not exist: ${file}`);
      process.exit(1);
    }
  });

  const cssFiles = (await Promise.all(files.map(async (file) => {
    const stats = await fs.stat(file);
    if (stats.isDirectory()) {
      return readDirectory(file);
    }
    return [file];
  }))).flat();

  await Promise.all(cssFiles.map((file) => optimizeFile(file)));
}

(async () => {
  const argv: any = yargs(hideBin(process.argv))
    .help(true)
    .version(false)
    .scriptName('cmmm')
    .command('$0 [file...] [options...]', 'General description...')
    .positional('file', {
      describe: 'Input file or directory paths', type: 'string',
    })
    .option('help', {
      alias: 'h', describe: 'Show usage', type: 'boolean',
    })
    .option('version', {
      alias: 'V', describe: 'Show current version', type: 'boolean',
    })
    .option('verbose', {
      alias: 'v', describe: 'Verbose logging', type: 'boolean',
    })
    .parse();

  if (argv.version) {
    console.log(`css-mini-mini-mini v${await getVersion()}`);
    return;
  }
  verbose = argv.verbose;

  if (!argv.file) {
    console.error('No file specified');
    process.exit(1);
  }

  // Yargs does not seem to parse multiple positionals correctly into the same property, so we have to workaround it
  const files = [argv.file].concat(argv.options);
  await optimizeFiles(files);
})();

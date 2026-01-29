import sharp from 'sharp';
import { mkdir, writeFile, readFile } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// iOS icon sizes (name: size in pixels)
const iosIcons = [
  { name: 'Icon-App-20x20@1x.png', size: 20 },
  { name: 'Icon-App-20x20@2x.png', size: 40 },
  { name: 'Icon-App-20x20@3x.png', size: 60 },
  { name: 'Icon-App-29x29@1x.png', size: 29 },
  { name: 'Icon-App-29x29@2x.png', size: 58 },
  { name: 'Icon-App-29x29@3x.png', size: 87 },
  { name: 'Icon-App-40x40@1x.png', size: 40 },
  { name: 'Icon-App-40x40@2x.png', size: 80 },
  { name: 'Icon-App-40x40@3x.png', size: 120 },
  { name: 'Icon-App-60x60@2x.png', size: 120 },
  { name: 'Icon-App-60x60@3x.png', size: 180 },
  { name: 'Icon-App-76x76@1x.png', size: 76 },
  { name: 'Icon-App-76x76@2x.png', size: 152 },
  { name: 'Icon-App-83.5x83.5@2x.png', size: 167 },
  { name: 'Icon-App-1024x1024@1x.png', size: 1024 },
];

// Android icon sizes (folder: size in pixels)
const androidIcons = [
  { folder: 'mipmap-mdpi', size: 48 },
  { folder: 'mipmap-hdpi', size: 72 },
  { folder: 'mipmap-xhdpi', size: 96 },
  { folder: 'mipmap-xxhdpi', size: 144 },
  { folder: 'mipmap-xxxhdpi', size: 192 },
];

// iOS Contents.json for the appiconset
const iosContentsJson = {
  images: [
    { size: '20x20', idiom: 'iphone', filename: 'Icon-App-20x20@2x.png', scale: '2x' },
    { size: '20x20', idiom: 'iphone', filename: 'Icon-App-20x20@3x.png', scale: '3x' },
    { size: '29x29', idiom: 'iphone', filename: 'Icon-App-29x29@1x.png', scale: '1x' },
    { size: '29x29', idiom: 'iphone', filename: 'Icon-App-29x29@2x.png', scale: '2x' },
    { size: '29x29', idiom: 'iphone', filename: 'Icon-App-29x29@3x.png', scale: '3x' },
    { size: '40x40', idiom: 'iphone', filename: 'Icon-App-40x40@2x.png', scale: '2x' },
    { size: '40x40', idiom: 'iphone', filename: 'Icon-App-40x40@3x.png', scale: '3x' },
    { size: '60x60', idiom: 'iphone', filename: 'Icon-App-60x60@2x.png', scale: '2x' },
    { size: '60x60', idiom: 'iphone', filename: 'Icon-App-60x60@3x.png', scale: '3x' },
    { size: '20x20', idiom: 'ipad', filename: 'Icon-App-20x20@1x.png', scale: '1x' },
    { size: '20x20', idiom: 'ipad', filename: 'Icon-App-20x20@2x.png', scale: '2x' },
    { size: '29x29', idiom: 'ipad', filename: 'Icon-App-29x29@1x.png', scale: '1x' },
    { size: '29x29', idiom: 'ipad', filename: 'Icon-App-29x29@2x.png', scale: '2x' },
    { size: '40x40', idiom: 'ipad', filename: 'Icon-App-40x40@1x.png', scale: '1x' },
    { size: '40x40', idiom: 'ipad', filename: 'Icon-App-40x40@2x.png', scale: '2x' },
    { size: '76x76', idiom: 'ipad', filename: 'Icon-App-76x76@1x.png', scale: '1x' },
    { size: '76x76', idiom: 'ipad', filename: 'Icon-App-76x76@2x.png', scale: '2x' },
    { size: '83.5x83.5', idiom: 'ipad', filename: 'Icon-App-83.5x83.5@2x.png', scale: '2x' },
    { size: '1024x1024', idiom: 'ios-marketing', filename: 'Icon-App-1024x1024@1x.png', scale: '1x' },
  ],
  info: { version: 1, author: 'xcode' },
};

async function generateIcons() {
  const svgPath = join(__dirname, 'truestate_icon.svg');
  const svgBuffer = await readFile(svgPath);

  // Create iOS assets directory
  const iosDir = join(__dirname, '../../ios/Runner/Assets.xcassets/AppIcon.appiconset');
  await mkdir(iosDir, { recursive: true });

  console.log('Generating iOS icons...');
  for (const icon of iosIcons) {
    const outputPath = join(iosDir, icon.name);
    await sharp(svgBuffer, { density: 300 })
      .resize(icon.size, icon.size)
      .png()
      .toFile(outputPath);
    console.log(`  ✓ ${icon.name} (${icon.size}x${icon.size})`);
  }

  // Write iOS Contents.json
  await writeFile(
    join(iosDir, 'Contents.json'),
    JSON.stringify(iosContentsJson, null, 2)
  );
  console.log('  ✓ Contents.json');

  // Generate Android icons
  console.log('\nGenerating Android icons...');
  for (const icon of androidIcons) {
    const androidDir = join(__dirname, '../../android/app/src/main/res', icon.folder);
    await mkdir(androidDir, { recursive: true });

    // Standard launcher icon
    const outputPath = join(androidDir, 'ic_launcher.png');
    await sharp(svgBuffer, { density: 300 })
      .resize(icon.size, icon.size)
      .png()
      .toFile(outputPath);
    console.log(`  ✓ ${icon.folder}/ic_launcher.png (${icon.size}x${icon.size})`);
  }

  // Generate Play Store icon (512x512)
  const playstoreDir = join(__dirname, '../../android/app/src/main/res');
  await sharp(svgBuffer, { density: 300 })
    .resize(512, 512)
    .png()
    .toFile(join(playstoreDir, 'playstore-icon.png'));
  console.log('  ✓ playstore-icon.png (512x512)');

  console.log('\n✅ All icons generated successfully!');
}

generateIcons().catch(console.error);

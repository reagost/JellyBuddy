import { chromium } from 'playwright';

async function main() {
  console.log('Launching browser (headed)...');
  const browser = await chromium.launch({
    headless: false,
    args: ['--disable-blink-features=AutomationControlled']
  });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1440, height: 900 });

  console.log('Navigating to Stitch...');
  await page.goto('https://stitch.withgoogle.com', { timeout: 60000 });

  // Wait for content to load
  await page.waitForTimeout(10000);

  // Take screenshot
  await page.screenshot({ path: 'stitch-headed.png', fullPage: false });
  console.log('Screenshot saved');

  // Get body text
  const body = await page.evaluate(() => document.body?.innerText || '');
  console.log('Body:', body.slice(0, 1000));

  // Check URL
  console.log('URL:', page.url());

  await browser.close();
}

main().catch(e => {
  console.error('Error:', e.message);
  process.exit(1);
});

// Screenshots of the Backrest web UI for the tutorial (run by screenshots.sh in
// a browser instance): first-run settings, repository, plan, backup, snapshot.
//   node screenshots.mjs <backrest URL> <output directory>
import { chromium } from "playwright-core";

const [url, out] = process.argv.slice(2);
const browser = await chromium.launch({ executablePath: "/usr/bin/chromium" });
const page = await browser.newPage({ viewport: { width: 1280, height: 960 }, timezoneId: "Europe/Paris" });
const shot = (name) => page.screenshot({ path: `${out}/${name}.png` });
const pause = (ms = 800) => page.waitForTimeout(ms);
const button = (name) => page.getByRole("button", { name, exact: true });
const toTop = (locator) => locator.evaluate((e) => e.scrollIntoView({ block: "start" }));

// First run: instance ID and an administrator account
await page.goto(url);
await page.getByPlaceholder("Unique instance ID").fill("backrest");
await page.getByText("Disable Authentication").click();
await button("Add user").click();
await page.getByPlaceholder("Username").fill("admin");
await page.getByPlaceholder("Password").fill("demo-password");
await toTop(page.getByText("Instance ID").first());
await pause();
await shot("settings");
await button("Save changes").click();
await pause(2500);

// Log in
await page.goto(url);
await page.getByPlaceholder("Username").fill("admin");
await page.getByPlaceholder("Password").fill("demo-password");
await button("Log in").click();
await pause(1500);

// Repository: restic repository on the backups volume
await button("Add Repo").click();
await pause();
await page.getByPlaceholder("repo1").fill("local");
await page.getByRole("combobox").first().fill("/backups/restic");
await page.locator("input[type=password]").first().fill("demo-repo-password");
await page.getByText("Repository URI").first().click();
await pause();
await shot("repo");
await button("Submit").click();
await pause(4000);

// Plan: the read-only data volume, every night at 3am
await button("Add Plan").click();
await pause();
await page.getByPlaceholder("plan1").fill("app-data");
await page.getByRole("combobox").filter({ hasText: "Select repository" }).click();
await page.getByRole("option", { name: "local" }).click();
await button("Add").first().click();
await page.getByPlaceholder("Paths").fill("/backup/app-data");
await page.getByText("Plan Name").first().click();
await page.locator('input[value="0 * * * *"]').fill("0 3 * * *");
await page.getByText("Plan Name").first().click();
await pause();
await shot("plan");
await page.getByText("Cron Expression").first().scrollIntoViewIfNeeded();
await pause();
await shot("plan-schedule");
await button("Submit").click();
await pause(3000);

// First backup, then its details and the snapshot browser
await page.getByText("app-data").first().click();
await pause();
await button("Backup Now").click();
await page.getByText(/ID: [0-9a-f]+/).first().waitFor({ timeout: 60000 });
await pause(2000);
await page.getByText(/ID: [0-9a-f]+/).first().click();
await pause(1500);
await shot("backup");
await button("Snapshot Browser").click();
await pause(1500);
for (const name of ["backup", "app-data", "documents"]) {
  await page.locator(".ant-tree-title, [role=treeitem]").filter({ hasText: new RegExp(`^${name}$`) }).first().click();
  await pause();
}
await toTop(page.getByText("Snapshot Browser").last());
await pause();
await shot("snapshot");

await browser.close();

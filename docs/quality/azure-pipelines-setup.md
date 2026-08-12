# AfterStorm Azure Pipelines Setup

AfterStorm keeps GitHub as the source repository. Azure Pipelines becomes the normal development CI lane so routine iOS builds do not consume GitHub Actions macOS minutes. GitHub's Xcode 27 workflow is manual-only and reserved for release verification.

## What is already in the repository

- `azure-pipelines.yml` — normal CI on Microsoft-hosted `macOS-26`.
- `.github/workflows/ios-ci.yml` — manual-only Xcode 27 release/simulator verification.
- The Azure pipeline:
  - checks out the GitHub repository,
  - selects the newest installed Xcode 26.x image,
  - runs `swift test`,
  - generates deterministic assets,
  - installs/runs XcodeGen,
  - validates WidgetKit metadata,
  - builds AfterStorm + widget for the iOS Simulator with signing disabled,
  - fails if Xcode emits warnings,
  - publishes the Xcode build log as an Azure artifact.

## One-time Azure DevOps connection

1. Sign in to Azure DevOps with the Microsoft account that owns the Azure for Students subscription.
2. Create or open an Azure DevOps organization.
3. Create a private project named **AfterStorm**.
4. In the organization settings, open **Billing** and link the valid Azure subscription. Microsoft currently requires the free Microsoft-hosted tier to be enabled; for a private project that tier provides one hosted job, up to 60 minutes per run, and 1,800 hosted minutes per month.
5. Open the **AfterStorm** project and choose **Pipelines → New pipeline**.
6. Choose **GitHub** as the code location.
7. Authorize/install the Azure Pipelines GitHub app if prompted.
8. Select **wscott2k26/AfterStorm**.
9. Choose **Existing Azure Pipelines YAML file**.
10. Select branch **feature/afterstorm-core-slice** while the work is still under review.
11. Select path **/azure-pipelines.yml**.
12. Save and run the pipeline.
13. Confirm the job uses the Microsoft-hosted `macOS-26` image and reaches the steps **Run AfterStormCore tests**, **Build AfterStorm and widget for iOS Simulator**, and **Require warning-clean Xcode build**.
14. After this feature branch is merged, edit the Azure pipeline's default branch to `main` if Azure did not update it automatically.

## If Microsoft-hosted parallelism is unavailable

New Azure DevOps organizations may not have Microsoft-hosted parallelism enabled immediately. Link the DevOps organization to the Azure subscription first. If the hosted job still reports that no parallelism is available, use Microsoft's Azure DevOps hosted-parallelism/free-tier request path. Do not buy extra capacity until the free tier has been checked.

## Cost-control rules for Storm and Me Studios

- Normal commits/PRs: Azure Pipelines.
- GitHub Actions Xcode 27 workflow: run manually only when a release candidate needs the newest Apple SDK/simulator evidence.
- Do not turn automatic `push` or `pull_request` triggers back on for the GitHub macOS workflow without an explicit reason.
- Keep the Azure job under its 60-minute private-project free-tier limit; split future test suites if needed.

## Current Apple toolchain split

- Azure development lane: newest Xcode 26.x installed on Microsoft-hosted `macOS-26` (currently Xcode 26.6 on the published runner image).
- GitHub release lane: `xcode-27` runner when manually dispatched.
- AfterStorm's iOS 27 multimodal image-understanding enhancement is compiler/availability-gated. On Xcode 26 or unsupported devices, Scan My World continues through the existing Vision/local fallback instead of blocking the app.

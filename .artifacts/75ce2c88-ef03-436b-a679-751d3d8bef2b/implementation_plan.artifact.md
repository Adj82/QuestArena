# Fix Vercel Deployment Output Directory Error

The Vercel deployment is failing because it expects an output directory named `public`, but the current build script either outputs to the root or `build/web`. Since Vercel's project settings are looking for `public`, I will adjust the build process to provide that directory.

## Proposed Changes

### [Build Configuration]

#### [MODIFY] [package.json](file:///C:/QuestArena/package.json)
- Update the `build` script to:
    1. Check if Flutter is already cloned (to save time on re-builds if supported).
    2. Build the Flutter web application.
    3. Create a `public` directory.
    4. Copy the build output from `build/web` into the `public` directory.

#### [MODIFY] [vercel.json](file:///C:/QuestArena/vercel.json)
- Ensure routing and SPA settings are correct. The current settings look fine for a Flutter SPA.

## Verification Plan

### Automated Tests
- I will run a local build and check if the `public` directory is correctly populated.

### Manual Verification
- The user will need to push the changes to GitHub to trigger the Vercel deployment again.
- Monitor the Vercel logs to ensure the `public` directory is found and the deployment succeeds.

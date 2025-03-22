# Gotify Client

[![License](https://img.shields.io/github/license/dhi13man/gotify_client)](https://github.com/Dhi13man/gotify_client/blob/main/LICENSE)
[![Contributors](https://img.shields.io/github/contributors-anon/dhi13man/gotify_client?style=flat)](https://github.com/Dhi13man/gotify_client/graphs/contributors)
[![GitHub forks](https://img.shields.io/github/forks/dhi13man/gotify_client?style=social)](https://github.com/Dhi13man/gotify_client/network/members)
[![GitHub Repo stars](https://img.shields.io/github/stars/dhi13man/gotify_client?style=social)](https://github.com/Dhi13man/gotify_client/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/dhi13man/gotify_client)](https://github.com/Dhi13man/gotify_client/commits/main)
[![Build, Format, Test](https://github.com/Dhi13man/gotify_client/workflows/Build,%20Format,%20Test/badge.svg)](https://github.com/Dhi13man/gotify_client/actions)

Thank you for investing your time in contributing to this project! Any contributions you make will help improve this Gotify Client for the entire community, and brightens up my day. :)

Make sure you familiarize yourself with [Gotify](https://gotify.net/) and its API before contributing!

## General Steps to Contribute

1. Ensure you have [Flutter SDK (>=2.19.0)](https://flutter.dev/docs/get-started/install/) installed.

2. Fork the [project repository](https://github.com/dhi13man/gotify_client/).

3. Clone the forked repository by running `git clone <forked-repository-git-url>`.

4. Navigate to your local repository by running `cd gotify_client`.

5. Pull the latest changes from upstream into your local repository by running `git pull`.

6. Create a new branch by running `git checkout -b <new-branch-name>`.

7. Make changes in your local repository to make the contribution you want.
    1. UI components go to `lib/src/ui/` directory.
    2. Service files and API communication go to `lib/src/services/`.
    3. Models and data classes go to `lib/src/models/`.
    4. Utility functions go to `lib/src/utils/`.

8. Add relevant tests for your contribution to the `test/` directory.

9. Run the tests to ensure everything works properly:

    ```sh
    flutter test
    ```

10. Make sure your code follows the project's style guidelines and passes linting:

    ```sh
    flutter analyze
    ```

11. Commit your changes and push them to your local repository:

    ```sh
    git commit -am "your descriptive commit message"
    git push origin <new-branch-name>
    ```

12. Create a pull request on the original repository from your fork and wait for review.

### Recommended Development Workflow

- Fork Project **->** Create new Branch
- For each contribution in mind,
  - **->** Implement feature or fix bug
  - **->** Add or update tests
  - **->** Ensure UI is consistent with the rest of the app
  - **->** Test on multiple platforms if possible (Android, iOS, Desktop)
  - **->** Check documentation
  - **->** Commit
- Create Pull Request

## Issue Based Contributions

### Create a new issue

If you spot a problem or bug with the application, search if an [issue](https://github.com/dhi13man/gotify_client/issues/) already exists. If a related issue doesn't exist, you can open a new issue using a relevant issue form.

### Solve an issue

Scan through our existing [issues](https://github.com/dhi13man/gotify_client/issues/) to find one that interests you. You can narrow down the search using labels as filters.

## Overall Guidelines

- Ensure your code is formatted using `flutter format .`
- Write clear, descriptive commit messages
- Include comments in your code where necessary
- Update documentation when changing functionality
- Add tests for new features
- Ensure the app works across multiple platforms (Android, iOS, Desktop)
- Respect the existing architecture and design patterns
- Be respectful and constructive when participating in discussions

Thank you for contributing to Gotify Client!

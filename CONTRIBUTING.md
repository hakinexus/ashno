# Contributing to Ashno

First off, thank you for considering contributing to Ashno! We're thrilled that you're interested in making this project even better. Your contributions help us create the definitive toolkit installer for the entire Termux community.

This document provides a set of guidelines for contributing to Ashno. These are mostly guidelines, not rigid rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## How Can I Contribute?

There are many ways you can contribute to the Ashno project, and all of them are valuable.

*   **Reporting Bugs**: Help us find and squash bugs to make Ashno more reliable.
*   **Suggesting Enhancements**: Propose new features, new packages for official profiles, or improvements to existing functionality.
*   **Improving Documentation**: Help us make the `README.md` and other documentation clearer and more comprehensive.
*   **Submitting Pull Requests**: Contribute directly to the codebase by fixing bugs or adding new features.

## Code of Conduct

This project and everyone participating in it is governed by the [Ashno Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior. *(Note: You will need to create this separate, simple file next)*

## Reporting Bugs

Before submitting a bug report, please take a moment to:

1.  **Update Ashno:** Make sure you are using the latest version by running `ashno --update`. The bug you're experiencing may have already been fixed.
2.  **Search Existing Issues:** Check the [Issues tab](https://github.com/hakinexus/ashno/issues) to see if someone else has already reported the same problem.

If you've checked and the issue seems to be new, please open a new issue. A well-written bug report is incredibly helpful. Be sure to include:

*   **A clear and descriptive title.**
*   **The exact command you ran.** (e.g., `ashno --profile 2_extended --pkg`)
*   **What you expected to happen.**
*   **What actually happened.** (Include any error messages, logs, or screenshots).
*   **Your environment.** (Termux version, Android version, device model).

## Suggesting Enhancements & New Packages

We would love to hear your ideas for making Ashno better! Whether it's a small tweak to the UI or a proposal for a brand-new official profile, we're open to suggestions.

When you submit an enhancement suggestion through the [Issues tab](https://github.com/hakinexus/ashno/issues), please be as clear as possible:

*   Use a clear and descriptive title.
*   Provide a step-by-step description of the suggested enhancement.
*   Explain why this enhancement would be useful to other Ashno users.

If you are proposing a new package for one of the official profiles (`1_essentials`, `2_extended`, `3_complete`), please provide a reason why it belongs in that specific tier.

## Your First Code Contribution (Pull Requests)

Ready to contribute code? We're excited to see what you've got.

#### Local Development Setup
1.  Fork the repository (`https://github.com/hakinexus/ashno/fork`).
2.  Clone your forked repository to your local machine (`git clone https://github.com/YourUsername/ashno.git`).
3.  Create a new branch for your feature or fix (`git checkout -b feature/MyAwesomeFeature` or `fix/MyBugFix`).

#### Making Your Changes
*   **Code Style**: Ashno is a `bash` script. Please follow standard shell scripting best practices. Aim for clarity and readability.
*   **Commit Messages**: Please follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification. This helps us maintain a clear and organized commit history.
    *   Example of a good commit message: `feat: Add self-update mechanism` or `fix: Corrected numbering in profile menu`.

#### Submitting a Pull Request
1.  Push your changes to your forked repository (`git push origin feature/MyAwesomeFeature`).
2.  Open a Pull Request from your branch to the `main` branch of the official Ashno repository.
3.  Provide a clear title and a detailed description of the changes you've made. Link to any relevant issues.

We will review your pull request as soon as possible. Thank you for your contribution!

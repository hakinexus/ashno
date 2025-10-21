<div align="center">
  <br/>
  <pre>
  
 █████╗  ██████╗ ██╗  ██╗███╗   ██╗ ██████╗ 
██╔══██╗██╔═══██╗██║  ██║████╗  ██║██╔═══██╗
███████║╚██████╗ ███████║██╔██╗ ██║██║   ██║
██╔══██║██╔═══██╗██╔══██║██║╚██╗██║██║   ██║
██║  ██║██████╔╝██║  ██║██║ ╚████║╚██████╔╝
╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
                                          
  </pre>
  <br/>
  <p>
    <strong>The Definitive, Professional Toolkit Installer for Termux</strong>
  </p>
  <br/>
    <p>
    <img alt="Version" src="https://img.shields.io/badge/version-1.0.0-blue?style=for-the-badge&logo=github">
    <img alt="Platform" src="https://img.shields.io/badge/platform-Termux-brightgreen?style=for-the-badge&logo=android">
    <img alt="License" src="https://img.shields.io/badge/license-MIT-purple?style=for-the-badge">
    <br>
    <img alt="Maintained" src="https://img.shields.io/badge/maintained%3F-yes-cyan.svg?style=for-the-badge">
    <img alt="Contributions" src="https://img.shields.io/badge/contributions-welcome-orange.svg?style=for-the-badge">
  </p>
  <br/>
</div>
  <br/>
</div>

**Ashno** is a state-of-the-art, framework-level tool designed to streamline and professionalize the setup of your Termux environment. It moves beyond simple scripts into a declarative, profile-driven system, allowing you to define, install, and manage complex toolkits with unparalleled ease and precision.

With a flawless, self-updating mechanism and a polished user interface, Ashno ensures your command-line environment is always powerful, consistent, and perfectly tailored to your needs.

---

### ◆ Key Features

*   **Profile-Driven Installation**: Install curated collections of `pkg`, `npm`, and `pip` packages based on tiered profiles—from a lightweight `Essentials` setup to a comprehensive `Complete` toolkit.
*   **Dynamic Custom Profiles**: Go beyond the defaults. Create your own profile directories to manage unique, personal, or project-specific toolkits. Ashno discovers and handles them automatically.
*   **Robust Self-Updating**: Ashno keeps itself up-to-date. The integrated updater safely pulls the latest features and profiles, ensuring you always have the best version without any manual effort.
*   **Professional UI & Real-Time Feedback**: A clean, modern interface with unmistakable real-time feedback for every package installation—know instantly what succeeded, failed, or was skipped.
*   **Intelligent & Safe**: Ashno is idempotent and safe to re-run. It detects local changes to prevent data loss during updates and correctly identifies existing packages to avoid redundant work.

---

### ◆ Installation

Choose the method that best suits your needs. For most users, the one-liner is the recommended approach for its speed and simplicity.

#### Recommended Method: One-Line Installer

This method is the fastest way to get started. It automatically clones the repository, sets the necessary permissions, and makes the `ashno` command globally available.

Open Termux and run this single command:

```bash
bash -c "$(curl -fsSL https://gist.githubusercontent.com/hakinexus/7df8c6853d98b2f7de95e92d5446765d/raw/d877e0568d53c30e27b4a59ef088b02175f7c748/Install.sh)"
```

#### For Developers: Manual Clone

This method is ideal if you wish to inspect the code, modify the profiles, or contribute to the project.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/hakinexus/ashno.git
    ```
2.  **Navigate into the directory:**
    ```bash
    cd ashno
    ```
3.  **Run the script directly:**
    ```bash
    ./ashno
    ```

---

### ◆ Usage

After installation, the `ashno` command is available from anywhere in your terminal.

#### Interactive Mode

Simply run the command without any arguments to launch the beautiful, interactive menu.

```bash
ashno
```

You will first be prompted to choose an installation profile, after which you can select which package categories (PKG, NPM, PIP) you wish to install.

#### Non-Interactive Mode (Flags)

For automation or quick installs, use the following command-line flags.

| Flag                       | Shorthand | Description                                                                        |
| -------------------------- | --------- | ---------------------------------------------------------------------------------- |
| `--profile <PROFILE_NAME>` |           | **Required.** Specifies the installation profile to use (e.g., `2_extended`).      |
| `--all`                    |           | **Action.** Installs all package types (`pkg`, `npm`, `pip`) for the profile.        |
| `--pkg`                    |           | **Action.** Installs only `pkg` packages for the profile.                          |
| `--npm`                    |           | **Action.** Installs only `npm` packages for the profile.                          |
| `--pip`                    |           | **Action.** Installs only `pip` packages for the profile.                          |
| `--update`                 | `-u`      | Checks for and applies updates to the Ashno script itself.                         |
| `--help`                   | `-h`      | Displays the comprehensive help manual.                                            |

**Example:**
```bash
# Install the full "Extended" profile non-interactively
ashno --profile 2_extended --all
```

---

### ◆ The Profiles System

Ashno's power comes from its profile-driven architecture. All profiles reside in the `profiles/` directory.

#### Official Tiered Profiles
The official profiles are **cumulative**. Selecting a higher tier automatically includes all packages from the lower tiers.

*   `1_essentials`: A lightweight, foundational setup.
*   `2_extended`: Includes everything in `Essentials` plus a wide array of tools for developers.
*   `3_complete`: Includes everything from the lower tiers plus a comprehensive toolkit for power users.

#### Creating Custom Profiles
Unleash the full potential of Ashno by creating your own profiles.

1.  Create a new directory inside the `profiles/` folder (e.g., `my_dev_env`).
2.  Inside your new directory, create `pkg.list`, `npm.list`, and/or `pip.list` files.
3.  Add the names of the packages you want, one per line. Use `#` for comments.

The next time you run `ashno`, your custom profile will appear in the selection menu, ready to use!

---

### ◆ Contributing

Contributions are what make the open-source community such an amazing place. Any contributions you make are **greatly appreciated**. Please feel free to fork the repo, create a pull request, or open an issue.

---

### ◆ License

Distributed under the MIT License. See `LICENSE` for more information.

---
<p align="center">
Crafted with passion by hakinexus
</p>

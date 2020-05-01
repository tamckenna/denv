# Complete DENV Setup

1. Login to the Apple App Store
2. Execute the Homebrew bundler by running the following command:
    * Will install applications listed in the [Brewfile](denv/Brewfile)

    ```bash
    cd $HOME/Desktop/denv && brew bundle
    ```

3. Restart sytem and hold [ Super+R ] to boot into Recovery mode
    * When in Recovery mode go to: Utilities -> Terminal
    * Run the following command (Take a picture or note since you will not be able to copy/paste)

    ```bash
    /Volumes/Macintosh\ HD/Users/admin/Desktop/denv/system-setup.sh
    ```

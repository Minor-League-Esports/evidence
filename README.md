# Evidence

### First Time Setup on Windows
1. Clone the Evidence Repository
    - In VS Code, hit `Ctrl+Shift+P` and type `Git: Clone`.  Hit enter or click on the matching result.
    - Paste the Evidence repo url into the text box and hit enter: https://github.com/Minor-League-Esports/evidence.git
    - Choose a destination folder to clone the repository into (usually people will just put it in their Documents folder).
    - A terminal window should open up saying the repo was successfully cloned.  VS Code may ask if you'd like to open up the repository, if so go ahead!

2. Download the Evidence VS Code Extension
    - Go to the Extensions menu of VS Code (located on the left toolbar, can just use `Ctrl+Shift+X` if you can't find it).
    - Search for "Evidence" in the search box.
    - Click Install for the "Evidence" and "DuckDB Driver for SQLTools" extensions.

3. Start Evidence Locally
    - You should now see a button on the bottom toolbar next to your branch management indicator that says "Start Evidence".
      - If you don't see this, try closing VS Code and then re-opening it with the folder that the repo is contained in.
    - Click the "Start Evidence" button.
      - If you get an error in the terminal that opens, try running the following commands one at a time in the same terminal:
        - `npm install`
        - `npm run sources`
        - `npm exec evidence dev -- --open`
      - The live testing/look at your changes should open in your browser after that last command.
      - Note that you wont need to do this again in the future, your "Start Evidence" should now work and open up in your browser as expected!


### Process Flow for Submitting Changes to the Repository
1. Before you do anything, create a new branch with the following format: `name/short_description_of_changes`
2. Click the "Start Evidence" button, you'll see it open in your browser with a live viewing window that gives you a live look in of the changes you're making.
3. Make your changes, ensuring that they look the way you expect in the browser window.
4. Commit your changes to the branch you made and push the branch/commit to the remote repository.
5. Go to the remote respository (https://github.com/Minor-League-Esports/evidence/) and create a Pull Request to merge your changes into the the `main` branch of code (this branch is what's used to actually construct the published MLE Evidence website and will be visible to all).
6. Notify OwnerOfTheWhiteSedan to review your PR and approve it or provide feedback with requested changes!  Once it's approved, it can be merged and seen by the MLE community!

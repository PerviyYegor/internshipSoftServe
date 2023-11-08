Task: Create a script to search for a specific word in a file every 15 minutes and write the results to a different file.

To achieve this, I followed a series of steps:

1. I implemented a loop to repeat the script execution at regular intervals. I added a sleep command at the end of an infinite loop, causing the script to pause for a specified number of seconds before running again.

2. I familiarized myself with the features of the `grep` command and learned how to combine it with `uniq` and `sort` to count the occurrences of the target word in each line.

3. I incorporated the necessary code to search for and count the occurrences of the word of interest in each line of the file.

4. I set up a pipeline to capture the output of these commands and direct it to a separate output file.

5. I introduced variables and command-line arguments to make the script more flexible.

6. I implemented checks to ensure that the required variables were provided by the user.

7. I added error messages in case of incorrect input and included a brief help message.



To use this script, follow these steps:

- Grant executable permissions to the script:
    ```
    chmod +x <pathToScript>
    ```

- Start the script:
  - With default values, the script will search for your specified word in the file every 15 minutes and write the output to `./output.txt`:
    ```
    /path/to/script/task1_script <yourWord> <pathToFile>
    ```
  - You can also customize the script by providing additional values:
    ```
    /path/to/script/task1_script <yourWord> <pathToFile> <secToWait> <pathToOutputFile>
    ```
  - If you want to run it easy and fast here is an example:
    ```
    git clone https://github.com/PerviyYegor/internshipSoftServe
    cd internshipSoftServe/task1
    ./task1_script information ./file.txt 5 output.txt
    ```
    this one is checking word 'information' in file `./file.txt` every 5 second and write output to `./output.txt`


That's it! Best of luck with the script. :)

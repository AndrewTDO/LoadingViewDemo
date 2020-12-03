# LoadingViewDemo
LoadView consists of progressView and a button to start processing tasks.

Test tasks are created in the testTasks() method.

The start() method starts executing all tasks, checking if the task has a parent task on which it depends, then it waits for the parent task to complete.

After all tasks are completed, the failed ones are filtered. If there is at least one - an alert appears with information (if there is only one failed task, the task ID will be displayed in the alert). Alert has two buttons Retry- to retry failed tasks, and Cancel.
After clicking on Retry, the application will execute all failed tasks again (for the test, they are always successful on the second attempt) and then an alert will be shown about the completion of all tasks successfully.


For testing:
In the testTasks method, you can change the number of tasks and their id, as well as which task is a subtask (child).
The Task class has a variable testSuccess - for random success value. Set this value to false or true to successfully or unsuccessfully complete the task.

The LoadingViewDemo app has a simple and user friendly interface.

Time spent:
To create the initial logic - about 60 minutes
To create UI components and configure them - 30 minutes
For displaying and processing logic results 110 minutes
Processing of results, various corrections and writing comments - 55 minutes
Readme file - 30 minutes

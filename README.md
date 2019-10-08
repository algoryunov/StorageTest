## Storage Test v0.9

### How to use the application:
0. This application is made by developers for developers, thus you can always check the code to find out how to use it.
1. Choose the Data Storage Type you would like to test
2. Setup the "Number Of Entities". Default value is 100'000, and probably this is a sufficient value
3. Tap on "Generate entities and save to DB". This will trigger generating specified number of 'Person' objects;

'Person' is the object that has id(Int), firstName(String), lastName(String) and birthDateTime(Double).
First/Last Names are taken from first-names and last-names json files from app's bundle. BirthDateTime is a random value.

4. Tap on 'Clear Database' if you want to remove all previously saved entities
5. Tap on 'Print Statistics' if you want to see the database file's size, or average duration of executed operations.
6. Tap on 'Print Query Helper' to find out what to enter in the 'search' text field.
Entered query will be used 'as is' and specified as a predicate (NSPredicate 'withFormat') for Core Data and Realm, or passed to SQLite as 'WHERE' clause.
Tap on 'Run' (near the 'Search' text field in order to (suprisingly) run the query) -> you will see the duration of executing the operation + total number of found entities + 10 found entities.

7. Tap on 'Help' to print *this* text.
8. Tap on 'Use Transactions' switch if you want to enable/disable using transactions for 'write' operation.
Note: Core Data and Realm are using transactions by default, so this switch is relevant for SQLite only

Screenshot:
![Screenshot:](https://github.com/algoryunov/StorageTest/blob/master/ReadmeSupportFiles/screenshot.png)


## The results I already captured:

### 1. Filesize of the database:
(can be useful if you are uploading your db from the customer's device for troubleshooting)

![Screenshot:](https://github.com/algoryunov/StorageTest/blob/master/ReadmeSupportFiles/filesize.png)


### 2. Search time. Note: no indexes yet
Search queries:
For Core Data and Realm:
(lastName ENDSWITH[cd] 'N') and ((firstName BEGINSWITH[cd] 'A') or (firstName CONTAINS[cd] 'NN')) and (birthDateTime > 1002499200)

For SQLite (I know it's not exactly the same as for Core Data and Realm, but it is ok for v0.9):
(lastName like '%N') and ((firstName like 'A%') or (firstName like '%nn%')) and (birthDateTime > 1002499200)

![Screenshot:](https://github.com/algoryunov/StorageTest/blob/master/ReadmeSupportFiles/searchtime.png)

### 3. Save time.
![Screenshot:](https://github.com/algoryunov/StorageTest/blob/master/ReadmeSupportFiles/save_time.png)

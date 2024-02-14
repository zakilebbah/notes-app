## Logic/Operations:

### Create:
- Generate a new, unique noteID for the note.
- Initialize syncStatus to "Unsynced".
- Set the version to 1.
- Record the current timestamp as dateCreated and dateModified.
### Read:
- All Notes: Retrieve a list of all notes, with an optional filter to show notes based on their syncStatus.
 By ID: Retrieve a specific note using its noteID.
- Excluding Soft Deleted: List notes where isDeleted is false.
### Update:
- Modify the title and/or content of the note.
- Update dateModified with the current timestamp.
- Increment the version by 1.
- If the syncStatus is "Synced", change it to "Unsynced".
### Delete:
- Instead of completely removing the note from the database, set the isDeleted flag to true. This marks the note as deleted without erasing its data.
- Change syncStatus to "Unsynced" to indicate that this change has not been reflected on the server or any other synced client.
### Syncing:
- On initiating a sync, fetch all notes from the local storage with syncStatus set to "Unsynced".
- Send these notes to the server. The server will use the noteID and version to check for conflicts.
 For each note, the server:
- Compares the version of the incoming note against the version it has.
- If the server's version is higher or there are discrepancies, it flags a conflict.
- If there is no conflict, the server updates its version.
- On successful sync of a note, the client updates the syncStatus to "Synced".
- For conflicting notes, the user is prompted to resolve the conflict, also there's an icon that indicates the conflict.

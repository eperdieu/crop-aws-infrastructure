## Tables
admin - Contains Admin login Credentials 
users - Contains Users login Credentials
programs - Stores Program information such as Name, Description, ID, etc


## Relationships
Admin table seems to be independent because it is used for authetication.
The programs table might have a many to many relationship because farmers can select multiple programs and counties.  

## Improvement Suggestions
Building off a former suggestion, we could add either a new database or add to an existing one for the recently viewed programs. This would be linked to the users table since it needs an ID.
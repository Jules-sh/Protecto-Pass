# Objects

This topic contains more about objects and their structure.

## Database

The Database is the actual object in which nearly the complete Database is stored.
It contains an array of entries and folders, which again contain an array of entries and folders, which can carry on for
as many instances as wanted.
The folders and the database itself is technically a subtype of ME_Datastructure, which stand for "
Multiple-Entity-Datastructure"

## ME_Datastructure

The ME_Datastructure is the class implementation which represents an entity, that itself can hold multiple other (or
same) entities again.
This results in the Core-Data relations to entries and folders, and additionally to videos and images as Loadable
Resources

## Loadable Resources

Not every resource and part of the Database may be loaded on app start or even when unlocking the Database due to a
lack of RAM or other performance issues.
To solve this problem a "Load-on-demand" structure is implemented, meaning storage-intensive data and resources such as
images, documents and videos are only loaded on demand, when the user actually wants to view them.

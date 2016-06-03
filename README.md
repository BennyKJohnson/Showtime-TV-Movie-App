# Showtime
CSCI342 Project

## Getting Started 

The project depends on third party libraries to run. For this project we used Carthage to manage these dependencies.
### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

Run `carthage update` to build the frameworks

Open the Xcode project and run the project.

## Classes

#### MasterViewController
Main View Controller which shows the tv shows and movies in CoreData in a TableView
#### ShowtimeClient
Client manager that handles the connections to third party web services
#### SearchViewController
TableViewController to handle the display of SearchResults in a TableView
#### Detail View Controller
TableViewController to display the contents of Movie or TV Show
#### TruncateTextView
Subclass of UITextView that truncates long text by hiding it partially and automatically provides a more button to reveal the entire content.
#### FilmCell
UITableViewCell to display a film or tv show
#### MovieDBRequest
An enum to handle the creation of request for the MovieDB API
#### Film
The parent entity for Movie and Show for providing shared properties
#### Movie
NSManagedObject for Movie entity
#### Show
NSManagedObject for Show entity 
#### Episode
NSManagedObject for Episode entity. Store information about an episode related to a show
#### Season
NSManagedObject for Season entity. Store information about a season related to a show
#### Formatter 
Singleton for storing a shared NSDateFormatter to minimise memory usage







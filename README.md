# wysh

 [![GitHub license](https://img.shields.io/badge/license-Apache%202-blue.svg?style=flat-square)](https://raw.githubusercontent.com/FuzzyWuzzie/wysh/master/LICENSE)

A self-hosted wishlist server + client.

TODO: documentation ;)

## Development

This section of the README is a scratch-pad for development; read at your own risk.

### User Stories (Server) / API Endpoints

#### Sign In / Registration

* [x] Sign In using Google or Facebook
* [x] If user doesn't already have an account, automatically create one
* [x] Automatically obtain name and profile picture from social sign in
* [x] Obtain refresh tokens so an active user is never signed out
* [ ] Obtain a refresh token automatically from oauth2?

#### Friends

* [x] Search for other users by name
* [x] Request friendship with found users
* [x] Accept friendship request
* [x] Reject friendship request
* [ ] See pending friendship requests
* [x] Un-friend someone

#### Lists

* [x] Create a new list with a name
* [x] Assign privacy settings to lists (at creation and later):
  + Private (only you can see the list)
  + Friends (only you & your friends can see the list)
  + Public (anyone with the link can view the list)
* [ ] Respect privacy settings when trying to access lists
  + [ ] When viewing a list
  + [ ] When viewing items on a list
  + [ ] When marking an item on a list as reserved

#### Items

* [x] Create a new item on a list
* [x] Edit an existing item on a list
* [x] Remove an item on a list
* [x] Mark an item on someone else's list as reserved
* [x] Prevent items on your own lists from being marked as reserved
* [x] Clear the reserved status of individual items on a list
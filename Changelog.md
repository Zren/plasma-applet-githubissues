## v3 - March 20 2019

* Hide comment button when there are 0 comments.
* Use an 18px heading (Issue #4)
* Can now customize the heading text (on top of hiding it)
* Fix panel icon to folow color scheme (Issue #7)
* Refactor code to be reuseable for other bug software.
* Support listing multiple repos at once.
* Issue list is cached to an sqlite db so restarting plasmashell doesn't re-fetch the list which would burn through your 60 unauthed requests/hour per IP.
* Merge partial chinese translations by @tobiichiamane (Pull Request #3)
* Merge dutch translations by @Vistaus (Pull Request #5 and #6)

## v2 - October 28 2018

* Fix the update timer not running.
* Add contextmenu action to manually refresh.
* Cleanup debug logging.

## v1 - October 28 2018

* Display first page of issues from a GitHub repo.
* Can display Open, Closed, or All Issues + Pull Requests.
* Lists number of comments like the webpage.
* Uses the same Octicons as the webpage.
* [Bug] All "closed" Pull Requests are shown as merged, even one's that are closed without merging.
* Can hide the background when used as a desktop widget.
* Can hide the heading.

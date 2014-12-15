tesoro
======

A simple web app to calculate taxes on capital gain according to the Danish tax system (skat means treasure in english and tesoro in italian)

It kind of works.

You can load some example data with.

```
rake db:migrate
rake db:seed
rails server
open http://0.0.0.0:3000/events
```

### TODO:
- Authentication
- Associate `Event` to a user
- Compute commission on sales
- Compute USD/DKK exchange

tesoro
======

![Example](http://f.cl.ly/items/432K1S3W3H0H2k1z3m31/Screen%20Shot%202014-12-16%20at%2000.59.39.png)

A simple web app to calculate taxes on capital gain according to the Danish tax system (skat means treasure in english and tesoro in italian)

It kind of works.

You can load some example data with.

```
rake db:migrate
rails server
open http://0.0.0.0:3000/
[create a user]
rake db:seed
```

### TODO:
- Compute commission on sales
- Compute USD/DKK exchange

# Trackman

Trackman is a Heroku add-on that enables you to handle your maintenance and error pages with the rest of your app and hosts the production version of those files in the cloud.

* It works with rails-like conventions that can be overriden if necessary.
* It is rack-based.
* It will push your pages and all their internal assets upon application initialization. 

## Information

### Platform support

Trackman works out of the box for

* Rails 2.x/3.x

## Getting started
### Step 1 - Install the addon
```console
heroku addons:add trackman
```
### Step 2 - Add the client gem to your Gemfile
```console
gem 'trackman'
```

### Step 3 - Setup
```console
rake trackman:setup
```
sets up your initial configuration and add custom error page addon if you don't have it yet.

### Optional
```console
rake trackman:sync
```
performs a manual sync of your error/maintenance pages and assets

### Notes
By convention, we assume your maintenance page is located at

```console
public/503.html
```

If you want two different pages for maintenance and when your app is down, we expect:

- For maintenance
```console
public/503.html
public/503-error.html
```
- Broken app
```console
public/503-error.html
```

After the add-on installation

* On the first publish or manual sync, your html file(s) and every internal assets referenced by your pages(s) will be pushed to our server so that we can store them properly on S3.
* On the next publications, only modified assets will be published. 
* Any renamed or missing asset will be handled properly on our side.

### Bug reports

Any bug report can be submitted here..
https://github.com/epetre/Bombero/issues


### Maintainers

* Jeremy Fabre (https://github.com/jfabre)
* Emanuel Petre (https://github.com/epetre)


## License

  Trackman client is released under the MIT license:

    www.opensource.org/licenses/MIT


# rename-ext-sh

> changes file-extension based on mime-type

also:

- removes `*?|^:"<>` characters from the file-name
- reducing multiple spaces, dots, and underscores
- adds rename-date suffix to ensure uniquness of the filename
- strips exec-flag from non-executive types ()
- optimizes images while at it (shows reduction size in `kb` and `%`)


## install and use

``` sh
PREFIX='/usr/local/'

git clone \
  https://github.com/dym-sh/rename-ext-sh.git \
  $PREFIX/src/rename-ext-sh/

chmod +x $PREFIX/src/rename-ext-sh/rename-ext.sh

ln -s $PREFIX/src/rename-ext-sh/rename-ext.sh \
      $PREFIX/bin/rename-ext
```

`rename-ext /Data/Pictures/_unsorted/**/*`

to only change extension and nothing else:

`rename-ext --only-ext /Data/Photos/2020/*`

to only print a report:

`rename-ext --test-run /Data/Docs/_dump/*`


## requires

- `cargo install sd` – better sed
- pngquant – to compress PNGs
- jpegoptim – to compress JPEGs


## TODO
- find better determination tool for `application/octet-stream`
- leverage `fd` to do recursive paralel execution if some of parameters are folders


## Q&A

**Q**: why not just rename files to hashes of their contents, and store original filenames in some database?

**A**: good point. that database is in my case a filesystem itself.
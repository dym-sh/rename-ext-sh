# rename-ext-sh

> changes file-extension based on mime-type

### also

- removes `*?|^:"<>` characters from the file-name
- reducing multiple spaces, dots, and underscores
- adds rename-date suffix to ensure uniquness of the filename
- strips exec-flag from non-executive types (usual leftover from FAT/NTFS)
- optimizes images while at it (shows reduction size in `kb` and `%`)


## [install](./install.sh) and use

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

- [`sd`](https://github.com/chmln/sd) – better sed
- [`pngquant`](https://github.com/kornelski/pngquant) – to compress PNGs
- [`jpegoptim`](https://github.com/tjko/jpegoptim) – to compress JPEGs


## todo
- find better determination tool for `application/octet-stream`
- leverage `fd` to do recursive paralel execution if some of parameters are folders


## q&a

**Q**: why not just rename files to hashes of their contents, and store original filenames in some database?

**A**: good point. that database is in my case a filesystem itself.


## mirrors
- [github](https://github.com/dym-sh/rename-ext-sh/)
- [src.dym.sh](https://src.dym.sh/rename-ext-sh/)
- `hyper://5e6376d12e75970b95ce254192716da1ce13623f40d4725c2e483a21150571be/` [[?](https://beakerbrowser.com)]


## license
[mit](./LICENSE)

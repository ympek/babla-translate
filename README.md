# babla-translate
Console utility to grab english&lt;->polish translation from bab.la dictionary. I wrote it because sometimes i wanted to look up a word without needing to leave my tmux workspace. This is like super basic script, naively relying on bab.la's HTML response, but it works for most cases. 

## usage

```
$ ruby babla.rb directly
directly = wprost, prosto, bezpośrednio, dosłownie, bezpośredni, wprost, szczery, bezadresowy, kierować, prowadzić, skierować, reżyserować, wyreżyserować, nakierować, dyrygować
```

in case you want some barely helpful debug prints, just add --verbose

```
$ ruby babla.rb abolish --verbose
Performing request to bab.la...
Processing response...
Done!
abolish = znieść, obalać, likwidować, usunąć, skasować, zlikwidować
```

for words with no polish diacritics, polish works too:
```
$ ruby babla.rb tworzywo
tworzywo = material
```
## todo

* handling UTF-8 - currently argument needs to be ASCII only.

[Wordle](https://www.nytimes.com/games/wordle/index.html) clone coded using Racket, specifically [ISL+](https://docs.racket-lang.org/htdp-langs/intermediate-lam.html) and the [2htdp/image](https://docs.racket-lang.org/teachpack/2htdpimage.html) library. Word validation uses the word lists from [this](https://github.com/Kinkelin/WordleCompetition/tree/main/data/official) repository. The `hashtable-extras` module was created by the teaching staff of [CS2500A](https://arjunguha.github.io/nu-2022F-CS2500Accel/).

To run, the latest version of Racket can be installed [here](https://download.racket-lang.org/)

Run the following command after navigating to the directory containing the code
```
$ racket wordle.rkt
```
Type to input a guess. Press ENTER to submit a guess.

![Wordle game state](https://media.cleanshot.cloud/media/45784/yvfq70H9EnQ281iYbB7l4MBB5WoLGZzL17vvctal.jpeg?Expires=1672708631&Signature=KlinnrUkM0c~HMUoGy6e06R5b~CdSysast~o~64dtZoRXPXty9HBnquAB4wux0-2GNF3TNphrywCDuevEmSXxGt5tHbxCytXIWG1e-qNJpw72-frPa59Y-AGCBWomEmm2AQS91RBZfmbWhjp6aAvo5SGBrqQhkX7LC11q6AG0mAoJRgTtjdvHTgSaDldjR24YtbGwaxEwMdYP3FtlJqT3iHzDGyFNiuBj9rPLAEShKv7Y4xOSOthmrdQAXOVwajlJyNdrrUp8tgrQKJa6KcyZ0RpBMMrdqNgaz8qsQKfi508w4Fq0x0QhR4kopFZPTj31rQ46c1M77dJUqcKOR6PKQ__&Key-Pair-Id=K269JMAT9ZF4GZ)

![Wordle fail state](https://media.cleanshot.cloud/media/45784/4IPE1oIRVcfNSfWkUpiii9g3DZmgjMXgzrltCsVV.jpeg?Expires=1672708785&Signature=SuyEzIfmoustJhP1JipGiYbTwKJyQz9jbBfD0n1MaXaKKb-uXAxi3qe3x0IC1GKlcvVwLcoF-L15IPYiu15vtuSx8pRWTjVxEahOBOQVJQ7QLnmxQPq3ql~h5p3PM0hlX-hjhpwXI0qrNEHAGzgd498mujGX-Q9yyBZS1ml5mxfmyJ2gDRxv52diDBywfg~oEXUwDWSRgJ3ufD2Exo9e~cO3Hl2HOuDlCinDtbF1hk71N2CUaNlFTXWYzG-93u34ZPw5ca1pEoronLpjSqipA2Q7mkG-xbGEVzFSPFKKD9HvE4TGJ8n5tPyGvNixtplQEUdRopMKIQ00bvR2ppAkXg__&Key-Pair-Id=K269JMAT9ZF4GZ)

![Wordle win state](https://media.cleanshot.cloud/media/45784/aAmHytpUDphw79rBscK41uNAOwqlCMQ43bGf7jeu.jpeg?Expires=1672708823&Signature=eLbNxwWuQlSWQUlprFprGlYdPz7cloEUuoOtmBFTwiAlkLhSnYW78FNYAj5Ky44qeeS7Ik6dVq4UMislNPfPfdsHXJyxE14K05BgrgsDO5EfLt1dmrzZPKrvOLgf~b6NmJ9cZ5r6Ez3gG2c50AqVc5TmYTN1sm~Yqx6-38NYpnDwSAKw4219rz7RItR91WBzeC84Oam~5dl528F-01IAVDvd-R-4hwpX7Rk02mlIayDuS-eTnexcJVKKwQjx4E1NOASEro15VkCyJ6VtY9a7wP4-Kts52n2Ufx54QIGRcQJFS5BjIT3Vm5SB7Fkcnnz3x-bsgr-v7mT3A-Etpa95uA__&Key-Pair-Id=K269JMAT9ZF4GZ)
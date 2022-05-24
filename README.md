# Praat
This is the TinyML Keyword Spotting project, named "Praat" because much of the spectrogram and feature obtaining strategies are inspired by those found in the Praat software.

Pretty much everything is in the `KeywordSpotting_PraatEndeavour.ipynb` and `Spectrogram Level Activities.ipynb` notebooks.
`Spectrogram Level Activities.ipynb` is the more recent one, and includes the latest feature extraction exploration, such as creating narrowband/broadband spectrograms and formants in a similar way to Praat, and extracting features such as [f] or [s] indicators.

`Spectrogram Level Activities.ipynb` uses spectrogram data ideally placed in `custom_spectrograms/{word}` where `{word}` can be any keyword such as `on`, `off`, etc. You can generate these in `Spectrogram Level Activities.ipynb` under the section: `This cell generates custom_spectrograms from audio wav files`.

Future work can entail starting with a neural network, and gradually peeling away the NN, replacing it with HDC components without degrading the accuracy.

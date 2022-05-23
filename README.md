# Praat
This is the TinyML Keyword Spotting project, named "Praat" because much of the spectrogram and feature obtaining strategies are inspired by those found in the Praat software.

Pretty much everything is in the `KeywordSpotting_PraatEndeavour.ipynb` and `Spectrogram Level Activities.ipynb` notebooks.
`Spectrogram Level Activities.ipynb` is the more recent one, and includes the latest feature extraction exploration, such as creating narrowband/broadband spectrograms and formants in a similar way to Praat, and extracting features such as [f] or [s] indicators.

`custom_spectrograms/` contains the spectrogram data used for `Spectrogram Level Activities.ipynb`. Only 300 samples of narrowband spectrograms were generated, you can generate more with the cell in `Spectrogram Level Activities.ipynb` under the section: `This cell generates custom_spectrograms from audio wav files`.

`broadband_short_text_database` and `narrowband_short_text_database` come from Praat, and are not used in the latest ipynb.

Future work can entail starting with a neural network, and gradually peeling away the NN, replacing it with HDC components without degrading the accuracy.

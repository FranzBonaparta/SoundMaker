1. Onde Sinusoïdale (Sine Wave)
math.sin(2 *math.pi* frequency * time)
🔹 Sonorité : Très doux, rond, sans harmonique.
🔹 Utilisation : Sons purs, effets simples, fond sonore calme.
2. Onde Carrée (Square Wave)
amplitude = amplitude or 0.3
    local samples = math.floor(duration * sampleRate)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples - 1 do
        local time = i / sampleRate
        local value = math.sin(2 *math.pi* frequency * time)
        -- Transforme en onde carrée
        if value >= 0 then
            value = amplitude
        else
            value = -amplitude
        end
        soundData:setSample(i, value)
    end
    (on "clippe" l'onde sinusoïdale en +amplitude ou -amplitude)

🔹 Sonorité : Très "8-bit", électronique, brut.
🔹 Utilisation : Bips, effets de tirs, menus de jeu rétro.
3. Onde Triangulaire (Triangle Wave)
Formule : une forme de "dent douce", comme une sinusoïde mais pointue.
Approximativement :
4 *math.abs((time* frequency - math.floor(time * frequency + 0.5))) - 1
(puis on multiplie par l'amplitude)

🔹 Sonorité : Plus douce que la carrée, mais plus "aigüe" que la sinusoïde.
🔹 Utilisation : Basse GameBoy, bruitages doux, mélodies secondaires.
4. Onde Dent de scie (Sawtooth Wave)
Formule : grimpe linéairement, puis redescend d'un coup :
2 *(time* frequency - math.floor(time * frequency + 0.5))
(pareil, à multiplier par amplitude)

🔹 Sonorité : Très "crissante", agressive, riche en harmoniques.
🔹 Utilisation : Effets spéciaux, sons de machines, bruitages "hardcore".

5. Bruit blanc (White Noise)
Pas vraiment une "onde" mais du pur chaos aléatoire :
(2 *math.random() - 1)* amplitude
chaque échantillon est aléatoire.

🔹 Sonorité : Shhhhhhhhhh (comme un poste radio entre deux stations).
🔹 Utilisation : Bruit de vent, explosions, frottements, feux.

|Note/octave|-1|0|1|2|3|4|5|6|7|8|9|
| ------- | ------- | ------- | ------- | ------- | ------- | -------| ------- | ------- | ------- | ------- | ------- |
|do ou si|16,35|32,70|65,41|130,81|261,63|523,25|1046,50|2093,00|4186,01|8 372,02|16 744,04|
|do ou ré|17,33|34,65|69,30|138,59|277,18|554,37|1108,73|2217,46|4434,92|8 869,84|17 739,68|
|ré|18,36|36,71|73,42|146,83|293,66|587,33|1174,66|2349,32|4698,64|9 397,28|18 794,56|
|ré ou mi|19,45|38,89|77,78|155,56|311,13|622,25|1244,51|2489,02|4978,03|9 956,06|19 912,12|
|mi ou fa|20,60|41,20|82,41|164,81|329,63|659,26|1318,51|2637,02|5274,04|10 548,08|21 096,16|
|fa ou mi|21,83|43,65|87,31|174,61|349,23|698,46|1396,91|2793,83|5587,65|11 175,30|22 350,60|
|fa ou sol|23,13|46,25|92,50|185,00|369,99|739,99|1479,98|2959,96|5919,91|11 839,82|23 679,64|
|sol|24,50|49,00|98,00|196,00|392,00|783,99|1567,98|3135,96|6271,93|12 543,86|25 087,72|
|sol ou la|25,96|51,91|103,83|207,65|415,30|830,61|1661,22|3322,44|6644,88|13 289,76|26 579,52|
|la|27,50|55,00|110,00|220,00|440,00|880,00|1760,00|3520,00|7040,00|14 080,00|28 160,00|
|la ou si|29,14|58,27|116,54|233,08|466,16|932,33|1864,66|3729,31|7458,62|14 917,24|29 834,48|
|si ou do|30,87|61,74|123,47|246,94|493,88|987,77|1975,53|3951,07|7902,13|15 804,26|31 608,52|

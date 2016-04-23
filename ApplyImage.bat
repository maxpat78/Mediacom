@echo off
REM Batch per l'installazione manuale di Windows 10 Home 1511 su tablet Mediacom
REM SmartPad 8.0 HD iPro 3G W810 (disco da 16GB e firmware UEFI).

REM Da usare previa preparazione delle partizioni GPT con Diskpart /s D:\CreatePartitions.txt
REM Si assume che il disco di installazione sia D:, come di regola.

REM Per adeguare eventuali lettere accentate, filtrare con: iconv -f cp1252 -t cp850 ApplyImage.bat

REM Per caricare un driver dal prompt di setup:
REM drvload D:\path_to_the_driver_inf_file.inf

if not exist S:\ goto errore
if not exist T:\ goto errore
if not exist W:\ goto errore

echo Applico l'immagine di Windows 10 Home alla partizione di Windows...
Dism /Apply-Image /ImageFile:D:\sources\install.wim /Index:2 /ApplyDir:W:\

echo Applico il codice Product-Key di Windows 8.1...
REM Errore: non pu• essere convalidato
Dism /Image:W:\ /Set-ProductKey:XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

echo Copio gli strumenti di Windows RE nella partizione dedicata...
md T:\Recovery\WindowsRE
copy W:\windows\system32\recovery\winre.wim T:\Recovery\WindowsRE\winre.wim

echo Copio i file di avvio dall'immagine di Windows alla partizione di Sistema EFI...
REM Occorre specificare la partizione di sistema, non la riconosce da solo come dovrebbe!
bcdboot W:\Windows /l it-it /s S: /f UEFI

echo Imposto la posizione degli strumenti di Windows RE nella partizione di Sistema EFI...
W:\Windows\System32\reagentc /setreimage /path T:\Recovery\WindowsRE /target W:\Windows

echo Applico i driver OEM per SmartPad 8.0...
REM Errore sul driver Intel IWD Bus Enumerator. Comunque, il setup ha successo!
REM Preparare dal precedente sistema Windows online con:
REM Dism /Online /Export-Driver /Destination:"D:\SmartPad\Drivers"
Dism /Image:W:\ /Add-Driver /Driver:"D:\SmartPad\Drivers" /Recurse

rem echo Applico gli ultimi aggiornamenti...
rem Errore: spazio/memoria insufficiente in Windows PE?
rem Dism /Image:W:\ /ScratchDir:W:\Windows\TEMP /Add-Package /PackagePath:D:\SmartPad\kb3147458.msu /PackagePath:D:\SmartPad\kb3140741.msu

echo Fatto.
echo Il tablet pu• essere riavviato per completare la configurazione di Windows.
goto fine

:errore
echo ERRORE: l'immagine di Windows 10 Home non pu• essere applicata, mancano
echo le tre partizioni richieste sul disco di sistema.
echo Preparare le partizioni GPT con "Diskpart /s D:\CreatePartitions.txt"
echo e accertarsi che siano state loro assegnate le lettere S, T e W.

:fine

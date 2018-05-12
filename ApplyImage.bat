@echo off
REM ~ Batch per l'installazione manuale di Windows 10

REM ~ Da usare previa preparazione delle partizioni GPT con
REM ~     Diskpart /s D:\CreatePartitions.txt

REM ~ Se non si indica il disco di installazione, assume D:

REM ~ Assume l'installazione dell'immagine 1 del WIM (Windows 10 Home)

REM ~ Per applicare un codice Product Key o un nome utente, aggiungere driver
REM ~ specifici o applicare aggiornamenti cumulativi, vedi le righe commentate

REM ~ Per adeguare eventuali lettere accentate, filtrare con
REM ~     iconv -f cp1252 -t cp850 ApplyImage.bat

REM ~ Per caricare un driver dal prompt di setup:
REM ~ drvload D:\path_to_the_driver_inf_file.inf

if not exist S:\ goto errore
if not exist T:\ goto errore
if not exist W:\ goto errore

set SRCDRIVE=D:
if not "$%1$"=="$$" set SRCDRIVE=%1

echo Assumo che i file di installazione sono in %SRCDRIVE%
if not exist %SRCDRIVE%\sources\install.wim goto nomedia

echo Applico l'immagine di Windows 10 Home alla partizione di Windows...
Dism /Apply-Image /ImageFile:%SRCDRIVE%\sources\install.wim /Index:1 /ApplyDir:W:\

REM ~ Per elencare le immagini disponibili:
REM ~ Dism /Get-WimInfo /WimFile:%SRCDRIVE%\sources\install.wim

REM ~ echo Applico il codice Product-Key di Windows...
REM ~ Errore: non pu• essere convalidato
REM ~ Dism /Image:W:\ /Set-ProductKey:XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

echo Copio gli strumenti di Windows RE nella partizione dedicata...
md T:\Recovery\WindowsRE
copy W:\windows\system32\recovery\winre.wim T:\Recovery\WindowsRE\WinRE.wim

echo Copio i file di avvio dall'immagine di Windows alla partizione di Sistema EFI...
REM ~ Occorre specificare la partizione di sistema, non la riconosce da solo come dovrebbe!
bcdboot W:\Windows /l it-it /s S: /f UEFI

echo Imposto la posizione degli strumenti di Windows RE nella partizione di Sistema EFI...
W:\Windows\System32\reagentc /setreimage /path T:\Recovery\WindowsRE /target W:\Windows

REM ~ echo Imposto il nome del proprietario del computer nel Registro...
REM ~ REG LOAD HKLM\Offline W:\Windows\System32\Config\Software
REM ~ REG ADD "HKLM\Offline\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /t REG_SZ /d "<IL TUO NOME QUI>" /f
REM ~ REG ADD "HKLM\Offline\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /t REG_SZ /f /ve
REM ~ REG UNLOAD HKLM\Offline

REM ~ echo Applico i driver OEM all'immagine di Windows...
REM ~ Dism /Image:W:\ /Add-Driver /Driver:"%SRCDRIVE%\Drivers" /Recurse

REM ~ Preparare dal precedente sistema Windows online con:
REM ~ Dism /Online /Export-Driver /Destination:"D:\Drivers"

REM ~ echo Applico gli ultimi aggiornamenti...
REM ~ Attenzione ai problemi di spazio/memoria insufficiente in Windows PE!
REM ~ Dism /Image:W:\ /ScratchDir:W:\Windows\TEMP /Add-Package /PackagePath:%SRCDRIVE%\kbXXXXXXXX.msu

echo Fatto.
echo Riavvier• il computer fra 10 secondi per configurare Windows:
echo attendere, oppure premere CTRL+C per prevenire il riavvio.
REM ~ Copiare TIMEOUT dalla cartella di sistema System32
if exist %SRCDRIVE%\timeout.exe %SRCDRIVE%\timeout.exe /t 10
wpeutil reboot
goto fine

:nomedia
echo ERRORE: i file di installazione di Windows non sono in %SRCDRIVE%
goto fine

:errore
echo ERRORE: l'immagine di Windows 10 non pu• essere applicata, mancano le tre
echo partizioni richieste sul disco di sistema.
echo Preparare le partizioni GPT con "Diskpart /s D:\CreatePartitions.txt"
echo e accertarsi che siano loro assegnate le lettere S, T e W.

:fine

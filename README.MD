AGGIORNAMENTO A WINDOWS 10 SU TABLET DA 16GB
============================================

# 1) Eseguire il backup del sistema da aggiornare

È consigliabile salvare su hard disk USB o altrove un'immagine del disco di
sistema del tablet (con Macrium Free, Clonezilla, Norton Ghost o altro
strumento) in modo da poter ripristinare Windows 8.1 in caso di problemi con
l'aggiornamento.

Facoltativamente, conservare un backup della chiave del registro di sistema:

    HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation

e della cartella C:\Windows\OEM, per poi ripristinarle nel nuovo sistema.

Con un'utilità quale ProduKey di NIRSoft annotare inoltre il codice product
key di Windows 8.1 (dovrebbe comunque essere memorizzato nel firmware della
macchina).


# 2) Preparare il disco di installazione

* N.B. MEDIACOM: a differenza del più recente WinPad 7" W700, il firmware UEFI
dello SmartPad 8.0 HD iPro W810 sembra in grado di riconoscere una chiavetta
USB o scheda SD come disco di avvio solo se partizionata in GPT e contenente
il bootloader EFI in una partizione avente GUID di tipo EFI SYSTEM, formattata
in FAT32. NON BASTA USARE TOOL OPEN-SOURCE COME RUFUS! *

Può essere preparata da un Prompt dei comandi amministrativo con DiskPart:

```
    select disk N
    clean
    convert gpt
    create partition efi
    format quick fs=fat32 label="Setup"
```

dove "N" è il numero del disco corrispondente alla chiavetta USB/scheda SD
rilevabile sempre da DiskPart con "list disk".

A questo punto basta copiare nella chiavetta/scheda il contenuto del DVD di
installazione di Windows 10 e usarla per l'avvio del tablet.


# 3) Backup dei driver OEM del tablet

È necessario effettuare il backup dei driver OEM specifici per il tablet,
affinché il nuovo sistema appena installato riconosca e configuri correttamente
periferiche peculiari quali l'accelerometro, il touch screen, il lettore di
SIM, ecc.
Dal sistema Windows 8.1 in esecuzione sul tablet, aprire un Prompt dei comandi
amministrativo e impartire:

```
    Dism /Online /Export-Driver /Destination:"D:\Drivers"
```

# 4) Avviare il tablet dal disco di installazione

Occorre premunirsi di un hub USB autoalimentato al quale collegare la chiavetta
(o la scheda SD in apposito lettore) USB e una tastiera e, eventualmente, anche
un mouse.

Acceso il tablet, prima che appaia il logo Mediacom, premere (anche
ripetutamente, per sicurezza) il TASTO ESC.

Un messaggio sotto il logo segnalerà la pressione e apparirà in breve un menù
con 6 icone: scegliere la seconda (Boot Manager) e premere INVIO o fare click.
Infine, dall'elenco "EFI Boot Devices", scegliere la chiavetta/scheda SD da
usare come disco di avvio e premere INVIO.

Va sottolineato che alcuni tablet sono in grado di alimentare una tastiera e
una chiavetta senza altre fonti di energia.

** PER INSTALLARE WINDOWS 10 IN ASSENZA DI TASTIERA, VEDERE LA NOTA "INSTALLARE
SENZA TASTIERA.TXT" **


# 5) Partizionare il disco di sistema

UN MERO AGGIORNAMENTO DI WINDOWS 8.1 NON SARA' VEROSIMILMENTE MAI RESO
POSSIBILE DA MEDIACOM in quanto il disco da 16 GB è insufficiente a
conservare il backup dei file di Windows 8.1 che l'installazione di Windows 10
mantiene al fine di recuperare il vecchio sistema in caso d'insuccesso.

Una volta fuse le partizioni di Windows 8.1 (ca. 9 GB) e di ripristino (ca. 5
GB) nell'unica partizione da 14 GB - come suggerito in alcuni forum - il
programma di setup di Windows 10 non riesce a individuare la destinazione dei
file di sistema o la partizione EFI dove copiare il bootloader o entrambe le
cose: e ciò anche eliminando tutte le partizioni e creandole da zero con lo
strumento grafico.

L'UNICA PROCEDURA SICURA E' PROCEDERE MANUALMENTE AL PROMPT DEI COMANDI
richiamabile con la pressione di MAIUSC+F10: ciò permette anche il massimo
controllo su ogni aspetto della preparazione del nuovo sistema.

A quel punto, avvalendosi degli script proposti di seguito e già copiati sul
disco di installazione, si compiranno i seguenti passi:

    a) creazione di tre partizioni (EFI, Windows e ripristino), sulla
    falsariga del WinPad W700 con Windows 10 nativo. Impartire:

        diskpart /s D:\CreatePartitions.txt

    b) installazione tramite DISM dell'immagine di Windows 10 Home,
    dell'ambiente di ripristino, del caricatore UEFI e dei driver OEM specifici
    per il tablet salvati al punto 3. Impartire:

        D:\ApplyImage

    c) riavvio e auto-configurazione finale. Chiudere la finestra del programma
    di installazione (che non è stata usata), oppure mantenere premuto per
    alcuni secondi il tasto di accensione per spegnere o impartire:
    
        wpeutil reboot

Al riavvio, Windows 10 configurerà in pochi minuti i dispositivi e si riavvierà
richiedendo le impostazioni finali (ad esempio, la password Wi-Fi).

Se al primo riavvio il tablet apparisse lento nelle risposte, riavviare ancora:
la velocità operativa dovrebbe tornare quella di sempre.

Windows dovrebbe rilevare automaticamente il codice product key (di Windows
8.1) registrato nel firmware del tablet e connettersi a Internet per attivare
Windows.

## Script pronti all'uso

Di seguito lo script DiskPart e il batch di comandi da copiare sulla
chiavetta/scheda di installazione e da eseguire al Prompt dei comandi (DiskPart
e DISM sono strumenti standard in dotazione a Windows da Vista in poi).

```
===== INIZIO - SCRIPT CreatePartitions.txt PER DISKPART ===
rem Partiziona automaticamente il disco di destinazione
rem dell'installazione di Windows 10 in modo UEFI/GPT

rem Invocare dal prompt del DVD di installazione (MAIUSC+F10) con:
rem    DiskPart /s D:\CreatePartitions.txt

select disk 0
clean
convert gpt
rem === 1. Partizione di sistema EFI =====
create partition efi size=100
format quick fs=fat32 label="System"
assign letter="S"

rem === 2. Partizione di Windows =====
create partition primary
shrink minimum=400
format quick fs=ntfs label="Windows"
assign letter="W"

rem === 3. Partizione di Windows RE =====
create partition primary
format quick fs=ntfs label="Windows RE tools"
assign letter="T"
set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
gpt attributes=0x8000000000000001

list volume
exit
===== FINE - SCRIPT CreatePartitions.txt PER DISKPART ===
```

```batchfile
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
===== FINE - BATCH ApplyImage.bat PER CMD ===
```

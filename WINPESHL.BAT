@echo off
echo L'installazione di Windows 10 sul tablet elimina ogni contenuto sul disco:
echo si desidera realmente continuare?
echo - PREMERE VOLUME+ PER CONFERMARE  L'INSTALLAZIONE
echo - PREMERE VOLUME- PER ABBANDONARE L'INSTALLAZIONE
echo.

vkclick wait
if not errorlevel 1 goto fine

echo PASSO 1. CREAZIONE DELLE NUOVE PARTIZIONI
diskpart /s D:\CreatePartitions.txt
echo PASSO 2. APPLICAZIONE DI WINDOWS 10
D:\ApplyImage.bat
echo Installazione completata. Premere un tasto per riavviare.
vkclick wait
wpeutil reboot

:fine

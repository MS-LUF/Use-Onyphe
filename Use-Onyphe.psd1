#
# Manifeste de module pour le module ��PSGet_Use-Onyphe��
#
# G�n�r� par�: LCU
#
# G�n�r� le�: 22/12/2017
#

@{

# Module de script ou fichier de module binaire associ� � ce manifeste
RootModule = 'use-onyphe.psm1'

# Num�ro de version de ce module.
ModuleVersion = '0.71'

# �ditions PS prises en charge
# CompatiblePSEditions = @()

# ID utilis� pour identifier de mani�re unique ce module
GUID = '85722cd6-f4a3-46b0-9d66-001f818e9a13'

# Auteur de ce module
Author = 'LCU'

# Soci�t� ou fournisseur de ce module
CompanyName = 'lucas-cueff.com'

# D�claration de copyright pour ce module
Copyright = '(c) 2018 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).'

# Description de la fonctionnalit� fournie par ce module
Description = 'Add few cmdlets to use API from onyphe.io through PowerShell interface'

# Version minimale du moteur Windows PowerShell requise par ce module
PowerShellVersion = '4.0'

# Nom de l'h�te Windows PowerShell requis par ce module
# PowerShellHostName = ''

# Version minimale de l'h�te Windows PowerShell requise par ce module
# PowerShellHostVersion = ''

# Version minimale du Microsoft .NET Framework requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# DotNetFrameworkVersion = ''

# Version minimale de l�environnement CLR (Common Language Runtime) requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# CLRVersion = ''

# Architecture de processeur (None, X86, Amd64) requise par ce module
# ProcessorArchitecture = ''

# Modules qui doivent �tre import�s dans l'environnement global pr�alablement � l'importation de ce module
# RequiredModules = @()

# Assemblys qui doivent �tre charg�s pr�alablement � l'importation de ce module
# RequiredAssemblies = @()

# Fichiers de script (.ps1) ex�cut�s dans l�environnement de l�appelant pr�alablement � l�importation de ce module
# ScriptsToProcess = @()

# Fichiers de types (.ps1xml) � charger lors de l'importation de ce module
# TypesToProcess = @()

# Fichiers de format (.ps1xml) � charger lors de l'importation de ce module
# FormatsToProcess = @()

# Modules � importer en tant que modules imbriqu�s du module sp�cifi� dans RootModule/ModuleToProcess
# NestedModules = @()

# Fonctions � exporter � partir de ce module. Pour de meilleures performances, n�utilisez pas de caract�res g�n�riques et ne supprimez pas l�entr�e. Utilisez un tableau vide si vous n�avez aucune fonction � exporter.
FunctionsToExport = 'Get-OnypheInfo', 'Get-OnypheInfoFromCSV', 
					 'Get-ScriptDirectory', 'Set-OnypheAPIKey', 
					 'Export-OnypheInfoToFile', 'Invoke-APIOnypheDataScan',
					 'Invoke-APIOnypheForward', 'Invoke-APIOnypheGeoloc',
					 'Invoke-APIOnypheIP', 'Invoke-APIOnypheInetnum', 'Invoke-APIOnypheMyIP',
					 'Invoke-APIOnyphePastries', 'Invoke-APIOnypheReverse',
					 'Invoke-APIOnypheSynScan', 'Invoke-APIOnypheThreatlist',
					 'Invoke-Onyphe','Get-OnypheUserInfo', 'Invoke-APIOnypheUser'


# Applets de commande � exporter � partir de ce module. Pour de meilleures performances, n�utilisez pas de caract�res g�n�riques et ne supprimez pas l�entr�e. Utilisez un tableau vide si vous n�avez aucune applet de commande � exporter.
CmdletsToExport = @()

# Variables � exporter � partir de ce module
# VariablesToExport = @()

# Alias � exporter � partir de ce module. Pour de meilleures performances, n�utilisez pas de caract�res g�n�riques et ne supprimez pas l�entr�e. Utilisez un tableau vide si vous n�avez aucun alias � exporter.
AliasesToExport = @()

# Ressources DSC � exporter depuis ce module
# DscResourcesToExport = @()

# Liste de tous les modules empaquet�s avec ce module
# ModuleList = @()

# Liste de tous les fichiers empaquet�s avec ce module
FileList = 'use-onyphe.psm1'

# Donn�es priv�es � transmettre au module sp�cifi� dans RootModule/ModuleToProcess. Cela peut �galement inclure une table de hachage PSData avec des m�tadonn�es de modules suppl�mentaires utilis�es par PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('API','onyphe.io','onyphe','shodan','search','engine')

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/MS-LUF/Use-Onyphe'

        # A URL to an icon representing this module.
        IconUri = 'https://www.onyphe.io/img/logo-solo.png'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# URI HelpInfo de ce module
# HelpInfoURI = ''

# Le pr�fixe par d�faut des commandes a �t� export� � partir de ce module. Remplacez le pr�fixe par d�faut � l�aide d�Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
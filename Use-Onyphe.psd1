#
# Manifeste de module pour le module « PSGet_Use-Onyphe »
#
# Généré par : LCU
#
# Généré le : 22/12/2017
#

@{

# Module de script ou fichier de module binaire associé à ce manifeste
RootModule = 'use-onyphe.psm1'

# Numéro de version de ce module.
ModuleVersion = '0.6'

# Éditions PS prises en charge
# CompatiblePSEditions = @()

# ID utilisé pour identifier de manière unique ce module
GUID = '85722cd6-f4a3-46b0-9d66-001f818e9a13'

# Auteur de ce module
Author = 'LCU'

# Société ou fournisseur de ce module
CompanyName = 'lucas-cueff.com'

# Déclaration de copyright pour ce module
Copyright = '(c) 2017 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).'

# Description de la fonctionnalité fournie par ce module
Description = 'Add few cmdlets to use API from onyphe.io through PowerShell interface'

# Version minimale du moteur Windows PowerShell requise par ce module
PowerShellVersion = '4.0'

# Nom de l'hôte Windows PowerShell requis par ce module
# PowerShellHostName = ''

# Version minimale de l'hôte Windows PowerShell requise par ce module
# PowerShellHostVersion = ''

# Version minimale du Microsoft .NET Framework requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# DotNetFrameworkVersion = ''

# Version minimale de l’environnement CLR (Common Language Runtime) requise par ce module. Cette configuration requise est valide uniquement pour PowerShell Desktop Edition.
# CLRVersion = ''

# Architecture de processeur (None, X86, Amd64) requise par ce module
# ProcessorArchitecture = ''

# Modules qui doivent être importés dans l'environnement global préalablement à l'importation de ce module
# RequiredModules = @()

# Assemblys qui doivent être chargés préalablement à l'importation de ce module
# RequiredAssemblies = @()

# Fichiers de script (.ps1) exécutés dans l’environnement de l’appelant préalablement à l’importation de ce module
# ScriptsToProcess = @()

# Fichiers de types (.ps1xml) à charger lors de l'importation de ce module
# TypesToProcess = @()

# Fichiers de format (.ps1xml) à charger lors de l'importation de ce module
# FormatsToProcess = @()

# Modules à importer en tant que modules imbriqués du module spécifié dans RootModule/ModuleToProcess
# NestedModules = @()

# Fonctions à exporter à partir de ce module. Pour de meilleures performances, n’utilisez pas de caractères génériques et ne supprimez pas l’entrée. Utilisez un tableau vide si vous n’avez aucune fonction à exporter.
FunctionsToExport = 'Set-OnypheAPIKey', 'Export-OnypheInfoToFile', 
               'Get-OnypheInfoFromCSV', 'Invoke-WebOnypheRequest', 
               'Get-ScriptDirectory'

# Applets de commande à exporter à partir de ce module. Pour de meilleures performances, n’utilisez pas de caractères génériques et ne supprimez pas l’entrée. Utilisez un tableau vide si vous n’avez aucune applet de commande à exporter.
CmdletsToExport = @()

# Variables à exporter à partir de ce module
# VariablesToExport = @()

# Alias à exporter à partir de ce module. Pour de meilleures performances, n’utilisez pas de caractères génériques et ne supprimez pas l’entrée. Utilisez un tableau vide si vous n’avez aucun alias à exporter.
AliasesToExport = @()

# Ressources DSC à exporter depuis ce module
# DscResourcesToExport = @()

# Liste de tous les modules empaquetés avec ce module
# ModuleList = @()

# Liste de tous les fichiers empaquetés avec ce module
FileList = 'use-onyphe.psm1'

# Données privées à transmettre au module spécifié dans RootModule/ModuleToProcess. Cela peut également inclure une table de hachage PSData avec des métadonnées de modules supplémentaires utilisées par PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('onyphe.io API','onyphe.io','onyphe','onyphe API','Use-Onyphe - Onyphe.io API with PowerShell')

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

# Le préfixe par défaut des commandes a été exporté à partir de ce module. Remplacez le préfixe par défaut à l’aide d’Import-Module -Prefix.
# DefaultCommandPrefix = ''

}


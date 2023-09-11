<#
    .SYNOPSIS
    Import-ADUsers.ps1
    .DESCRIPTION
    Importe des utilisateurs dans Active Directory à partir d'un fichier CSV.
#>

# Demander le chemin du fichier CSV
$FichierCsv = Read-Host -Prompt "Veuillez entrer le chemin complet du fichier CSV :"

if (-not (Test-Path $FichierCsv)) {
    Write-Error "Le fichier spécifié n'existe pas. Veuillez fournir un chemin valide."
    exit
}

$Utilisateurs = Import-Csv $FichierCsv

# Importer le module Active Directory
Import-Module ActiveDirectory

function Get-ManagerDN {
    param (
        [string]$NomAfficheManager
    )

    if ($NomAfficheManager) {
        return Get-ADUser -Filter "DisplayName -eq '$NomAfficheManager'" -Properties DisplayName |
               Select-Object -ExpandProperty DistinguishedName
    }
    return $null
}

function New-ADUserFromCSV {
    param (
        [PSCustomObject]$Utilisateur
    )

    $Prenom = $Utilisateur.'First name'
    $Nom = $Utilisateur.'Last name'
    $NomAffiche = $Utilisateur.'Display name'
    $NomCompte = $Utilisateur.'User logon name'
    $NomPrincipal = $Utilisateur.'User principal name'
    $Adresse = $Utilisateur.'Street'
    $Ville = $Utilisateur.'City'
    $Etat = $Utilisateur.'State/province'
    $CodePostal = $Utilisateur.'Zip/Postal Code'
    $Pays = $Utilisateur.'Country/region'
    $Titre = $Utilisateur.'Job Title'
    $Departement = $Utilisateur.'Department'
    $Entreprise = $Utilisateur.'Company'
    $Manager = Get-ManagerDN -NomAfficheManager $Utilisateur.'Manager'
    $OU = $Utilisateur.'OU'
    $Description = $Utilisateur.'Description'
    $Bureau = $Utilisateur.'Office'
    $Telephone = $Utilisateur.'Telephone number'
    $Email = $Utilisateur.'E-mail'
    $Mobile = $Utilisateur.'Mobile'
    $Notes = $Utilisateur.'Notes'
    $StatutCompte = $Utilisateur.'Account status'

    # Vérifier si l'utilisateur existe déjà dans AD
    $UtilisateurExiste = Get-ADUser -Filter { SamAccountName -eq $NomCompte } -ErrorAction SilentlyContinue

    if ($UtilisateurExiste) {
        Write-Warning "L'utilisateur '$NomCompte' existe déjà dans Active Directory."
        return
    }

    # Paramètres pour le nouvel utilisateur
    $ParamsNouvelUtilisateur = @{
        Name                  = "$Prenom $Nom"
        GivenName             = $Prenom
        Surname               = $Nom
        DisplayName           = $NomAffiche
        SamAccountName        = $NomCompte
        UserPrincipalName     = $NomPrincipal
        StreetAddress         = $Adresse
        City                  = $Ville
        State                 = $Etat
        PostalCode            = $CodePostal
        Country               = $Pays
        Title                 = $Titre
        Department            = $Departement
        Company               = $Entreprise
        Manager               = $Manager
        Path                  = $OU
        Description           = $Description 
        Office                = $Bureau
        OfficePhone           = $Telephone
        EmailAddress          = $Email
        MobilePhone           = $Mobile
        AccountPassword       = (ConvertTo-SecureString "P@ssw0rd1234" -AsPlainText -Force)
        Enabled               = if ($StatutCompte -eq "Enabled") { $true } else { $false }
        ChangePasswordAtLogon = $true # L'utilisateur doit changer le mot de passe lors de la prochaine connexion
    }

    if (![string]::IsNullOrEmpty($Notes)) {
        $ParamsNouvelUtilisateur.OtherAttributes = @{info = $Notes }
    }

    try {
        New-ADUser @ParamsNouvelUtilisateur
        Write-Host "Utilisateur $NomCompte créé avec succès." -ForegroundColor Cyan
    }
    catch {
        Write-Warning "Échec de la création de l'utilisateur $NomCompte. $_"
    }
}

# Créer les utilisateurs dans Active Directory
foreach ($Utilisateur in $Utilisateurs) {
    New-ADUserFromCSV -Utilisateur $Utilisateur
}

$ErrorActionPreference = 'Stop'
$devicon = 'https://raw.githubusercontent.com/devicons/devicon/master/icons'
$lobe = 'https://raw.githubusercontent.com/lobehub/lobe-icons/master/packages/static-svg/icons'
$logos = @(
    @{ Name = 'NumPy'; File = 'numpy'; Source = "$devicon/numpy/numpy-original.svg"; Size = 38 },
    @{ Name = 'Pandas'; File = 'pandas'; Source = "$devicon/pandas/pandas-original.svg"; Background = '#F5F7FA'; Size = 36 },
    @{ Name = 'Matplotlib'; File = 'matplotlib'; Source = "$devicon/matplotlib/matplotlib-original.svg"; Background = '#FFFFFF'; Size = 40 },
    @{ Name = 'Seaborn'; File = 'seaborn'; Source = 'https://raw.githubusercontent.com/gilbarbara/logos/main/logos/seaborn-icon.svg'; Background = '#FFFFFF'; Size = 40 },
    @{ Name = 'Scikit-learn'; File = 'scikitlearn'; Source = "$devicon/scikitlearn/scikitlearn-original.svg"; Background = '#FFFFFF'; Size = 40; ViewBox = '0 25 128 78' },
    @{ Name = 'Jupyter'; File = 'jupyter'; Source = "$devicon/jupyter/jupyter-original.svg"; Background = '#FFFFFF'; Size = 36 },
    @{ Name = 'Hugging Face'; File = 'huggingface'; Source = "$lobe/huggingface-color.svg"; Size = 40 },
    @{ Name = 'Gradio'; File = 'gradio'; Source = "$lobe/gradio-color.svg"; Size = 38 },
    @{ Name = 'Streamlit'; File = 'streamlit'; Source = "$devicon/streamlit/streamlit-original.svg"; Background = '#FFFFFF'; Size = 38; ViewBox = '0 30 128 72' },
    @{ Name = 'Google Colab'; File = 'colab'; Source = "$lobe/colab-color.svg"; Size = 38 },
    @{ Name = 'Kaggle'; File = 'kaggle'; Source = "$devicon/kaggle/kaggle-original.svg"; Size = 34 },
    @{ Name = 'Codex'; File = 'codex'; Source = "$lobe/codex-color.svg"; Background = '#FFFFFF'; Size = 48 },
    @{ Name = 'Antigravity'; File = 'antigravity'; Source = "$lobe/antigravity-color.svg"; Background = '#FFFFFF'; Size = 38 },
    @{ Name = 'Wispr Flow'; File = 'wispr-flow'; Source = 'https://cdn.prod.website-files.com/682f84b3838c89f8ff7667db/6a4eb4bec64ffc5de76e6db3_faq-wispr-logo.svg'; Background = '#034F46'; Size = 36; ViewBox = '6 6 16 16'; RemoveBackground = $true }
)

$namespace = 'http://www.w3.org/2000/svg'
$tiles = foreach ($logo in $logos) {
    $response = Invoke-WebRequest -UseBasicParsing -Uri $logo.Source
    $source = New-Object System.Xml.XmlDocument
    $source.XmlResolver = $null
    $source.LoadXml($response.Content)
    if ($source.DocumentElement.LocalName -ne 'svg') {
        throw "Invalid SVG source for $($logo.Name)"
    }

    $document = New-Object System.Xml.XmlDocument
    $root = $document.CreateElement('svg', $namespace)
    $root.SetAttribute('width', '48')
    $root.SetAttribute('height', '48')
    $root.SetAttribute('viewBox', '0 0 48 48')
    $root.SetAttribute('role', 'img')
    $root.SetAttribute('aria-labelledby', 'title description')
    [void]$document.AppendChild($root)

    $title = $document.CreateElement('title', $namespace)
    $title.SetAttribute('id', 'title')
    $title.InnerText = $logo.Name
    [void]$root.AppendChild($title)
    $description = $document.CreateElement('desc', $namespace)
    $description.SetAttribute('id', 'description')
    $description.InnerText = "$($logo.Name) brand mark. Source: $($logo.Source)"
    [void]$root.AppendChild($description)

    $background = $document.CreateElement('rect', $namespace)
    $background.SetAttribute('width', '48')
    $background.SetAttribute('height', '48')
    $background.SetAttribute('rx', '10')
    $background.SetAttribute('fill', $(if ($logo.Background) { $logo.Background } else { '#242938' }))
    [void]$root.AppendChild($background)

    $artwork = $document.ImportNode($source.DocumentElement, $true)
    $artwork.RemoveAttribute('style')
    $artwork.SetAttribute('x', [string]((48 - $logo.Size) / 2))
    $artwork.SetAttribute('y', [string]((48 - $logo.Size) / 2))
    $artwork.SetAttribute('width', [string]$logo.Size)
    $artwork.SetAttribute('height', [string]$logo.Size)
    $artwork.SetAttribute('preserveAspectRatio', 'xMidYMid meet')
    if ($logo.ViewBox) {
        $artwork.SetAttribute('viewBox', $logo.ViewBox)
    }
    if ($logo.RemoveBackground) {
        $rect = $artwork.SelectSingleNode('./*[local-name()="rect"]')
        if ($rect) { [void]$artwork.RemoveChild($rect) }
    }
    [void]$root.AppendChild($artwork)
    if ($logo.Background -in @('#FFFFFF', '#F5F7FA')) {
        $outline = $document.CreateElement('rect', $namespace)
        $outline.SetAttribute('x', '0.5')
        $outline.SetAttribute('y', '0.5')
        $outline.SetAttribute('width', '47')
        $outline.SetAttribute('height', '47')
        $outline.SetAttribute('rx', '9.5')
        $outline.SetAttribute('fill', 'none')
        $outline.SetAttribute('stroke', '#D0D7DE')
        [void]$root.AppendChild($outline)
    }
    if ($root.SelectNodes('.//*[local-name()="script" or local-name()="foreignObject" or local-name()="image"]').Count -gt 0) {
        throw "Unexpected active or external content in $($logo.Name)"
    }
    @{ File = $logo.File; Document = $document }
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.OmitXmlDeclaration = $true
$settings.Encoding = New-Object System.Text.UTF8Encoding($false)
foreach ($tile in $tiles) {
    $path = Join-Path $PSScriptRoot "icons/$($tile.File).svg"
    $writer = [System.Xml.XmlWriter]::Create($path, $settings)
    try { $tile.Document.Save($writer) } finally { $writer.Dispose() }
    $check = New-Object System.Xml.XmlDocument
    $check.Load($path)
    if ($check.DocumentElement.GetAttribute('viewBox') -ne '0 0 48 48') {
        throw "Invalid output dimensions: $path"
    }
}
Write-Output "PASS: generated and XML-validated $($tiles.Count) self-contained 48px logo tiles."
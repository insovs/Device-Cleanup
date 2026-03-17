#Requires -RunAsAdministrator

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Hide the PowerShell console window
$consolePtr = [System.Runtime.InteropServices.Marshal]::GetIUnknownForObject([System.Console]::Out)
Add-Type -Name Win32 -Namespace Hide -MemberDefinition '
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]   public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
' -ErrorAction SilentlyContinue
try { [Hide.Win32]::ShowWindow([Hide.Win32]::GetConsoleWindow(), 0) } catch {}
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml

[void][System.Windows.Shapes.Ellipse]
[void][System.Windows.Controls.CheckBox]
[void][System.Windows.Controls.Border]
[void][System.Windows.Controls.StackPanel]
[void][System.Windows.Controls.TextBlock]
[void][System.Windows.Controls.Primitives.Thumb]

function Parse-Xaml {
    param([string]$s)
    [xml]$x = $s.Trim()
    return [System.Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($x))
}

$mainXaml = @'
<Window
  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Device Cleanup"
  Width="840" Height="640"
  MinWidth="640" MinHeight="460"
  WindowStartupLocation="CenterScreen"
  Background="Transparent"
  Foreground="#E8E8F0"
  FontFamily="Segoe UI"
  WindowStyle="None"
  AllowsTransparency="True"
  ResizeMode="NoResize">

  <Window.Resources>

    <Style x:Key="PrimaryBtn" TargetType="Button">
      <Setter Property="Background" Value="#3B82F6"/><Setter Property="Foreground" Value="White"/>
      <Setter Property="FontSize" Value="13"/><Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="22,10"/><Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="Background" Value="#2563EB"/></Trigger>
              <Trigger Property="IsPressed"   Value="True"><Setter TargetName="bd" Property="Background" Value="#1D4ED8"/></Trigger>
              <Trigger Property="IsEnabled"   Value="False">
                <Setter TargetName="bd" Property="Background" Value="#1A1A24"/><Setter Property="Foreground" Value="#374151"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="DangerBtn" TargetType="Button">
      <Setter Property="Background" Value="#16A34A"/><Setter Property="Foreground" Value="White"/>
      <Setter Property="FontSize" Value="13"/><Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="22,10"/><Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="Background" Value="#22C55E"/></Trigger>
              <Trigger Property="IsPressed"   Value="True"><Setter TargetName="bd" Property="Background" Value="#15803D"/></Trigger>
              <Trigger Property="IsEnabled"   Value="False">
                <Setter TargetName="bd" Property="Background" Value="#1A1A24"/><Setter Property="Foreground" Value="#374151"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="GhostBtn" TargetType="Button">
      <Setter Property="Background" Value="#1C1C26"/><Setter Property="Foreground" Value="#9CA3AF"/>
      <Setter Property="FontSize" Value="12"/><Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="14,8"/><Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="7" Padding="{TemplateBinding Padding}" BorderBrush="#252530" BorderThickness="1">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="Background" Value="#252530"/></Trigger>
              <Trigger Property="IsEnabled"   Value="False">
                <Setter TargetName="bd" Property="Background" Value="#111118"/><Setter Property="Foreground" Value="#374151"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="WinBtn" TargetType="Button">
      <Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#6B7280"/>
      <Setter Property="FontSize" Value="12"/><Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/><Setter Property="Width" Value="32"/><Setter Property="Height" Value="26"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="Transparent" CornerRadius="5">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="Background" Value="#252530"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="CloseBtn" TargetType="Button">
      <Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#6B7280"/>
      <Setter Property="FontSize" Value="12"/><Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/><Setter Property="Width" Value="32"/><Setter Property="Height" Value="26"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="Transparent" CornerRadius="5">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#7F1D1D"/><Setter Property="Foreground" Value="#EF4444"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ScrollBar">
      <Setter Property="Background" Value="Transparent"/><Setter Property="Width" Value="5"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ScrollBar">
            <Grid>
              <Track x:Name="PART_Track" IsDirectionReversed="True">
                <Track.Thumb>
                  <Thumb>
                    <Thumb.Template>
                      <ControlTemplate TargetType="Thumb">
                        <Border Background="#2D2D3D" CornerRadius="3"/>
                      </ControlTemplate>
                    </Thumb.Template>
                  </Thumb>
                </Track.Thumb>
              </Track>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

  </Window.Resources>

  <Grid x:Name="RootGrid">
    <Border x:Name="MainBorder" CornerRadius="12" Background="#0A0A0F" BorderBrush="#1E1E2E" BorderThickness="1" Margin="4">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="50"/><RowDefinition Height="*"/><RowDefinition Height="58"/>
        </Grid.RowDefinitions>
        <Border Grid.Row="0" Background="#0D0D15" CornerRadius="12,12,0,0">
          <Grid Margin="18,0">
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
              <Ellipse Width="7" Height="7" Fill="#3B82F6" Margin="0,0,9,0"/>
              <TextBlock Text="DEVICE"    FontSize="13" FontWeight="Bold" Foreground="#3B82F6" VerticalAlignment="Center"/>
              <TextBlock Text="  CLEANUP" FontSize="13" FontWeight="Bold" Foreground="#E8E8F0" VerticalAlignment="Center"/>
              <Border Background="#1C1C26" CornerRadius="4" Padding="8,2" Margin="12,0,0,0">
                <TextBlock Text="GHOST DEVICE REMOVER" FontSize="10" Foreground="#2D3748" FontWeight="SemiBold" VerticalAlignment="Center"/>
              </Border>
              <Border x:Name="GithubBtn" Background="#0D1520" BorderBrush="#1A2535" BorderThickness="1" CornerRadius="4" Padding="8,2" Margin="8,0,0,0" Cursor="Hand">
                <TextBlock Text="github / insovs" FontSize="10" Foreground="#3B82F6" VerticalAlignment="Center"/>
              </Border>
            </StackPanel>
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
              <Button x:Name="BtnMinimize" Content="&#x2014;" Style="{StaticResource WinBtn}"/>
              <Button x:Name="BtnClose"    Content="&#x2715;" Style="{StaticResource CloseBtn}" Margin="4,0,0,0"/>
            </StackPanel>
          </Grid>
        </Border>
        <Grid Grid.Row="1" Margin="16,12,16,0">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="205"/><ColumnDefinition Width="12"/><ColumnDefinition Width="*"/>
          </Grid.ColumnDefinitions>
          <Grid Grid.Column="0" Margin="0,0,0,6">
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <Border Grid.Row="0" Background="#111118" CornerRadius="10" Padding="14,12" BorderBrush="#1E1E2E" BorderThickness="1" Margin="0,0,0,8">
              <StackPanel>
                <TextBlock Text="STATUS" FontSize="10" FontWeight="Bold" Foreground="#374151" Margin="0,0,0,8"/>
                <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                  <Ellipse x:Name="StatusDot" Width="7" Height="7" Fill="#374151" Margin="0,0,7,0" VerticalAlignment="Center"/>
                  <TextBlock x:Name="StatusLabel" Text="Ready to scan" Foreground="#6B7280" FontSize="12"/>
                </StackPanel>
                <Border Background="#0D0D15" CornerRadius="3" Height="4">
                  <Border x:Name="ProgressBar" Background="#3B82F6" CornerRadius="3" Width="0" HorizontalAlignment="Left" Height="4"/>
                </Border>
              </StackPanel>
            </Border>

            <Border Grid.Row="1" Background="#111118" CornerRadius="10" Padding="14,12" BorderBrush="#1E1E2E" BorderThickness="1" Margin="0,0,0,8">
              <StackPanel>
                <TextBlock Text="SCAN RESULTS" FontSize="10" FontWeight="Bold" Foreground="#374151" Margin="0,0,0,10"/>
                <TextBlock Text="Ghost Devices" Foreground="#4B5563" FontSize="11"/>
                <TextBlock Text="removable from registry" Foreground="#252535" FontSize="9" Margin="0,1,0,2"/>
                <TextBlock x:Name="TxtGhostCount"     Text="-" Foreground="#EF4444" FontSize="24" FontWeight="Bold" Margin="0,1,0,6"/>
                <Border Background="#1C1C26" Height="1" Margin="0,0,0,8"/>
                <TextBlock Text="Protected" Foreground="#4B5563" FontSize="11"/>
                <TextBlock Text="CPU affinity configured" Foreground="#252535" FontSize="9" Margin="0,1,0,2"/>
                <TextBlock x:Name="TxtProtectedCount" Text="-" Foreground="#F59E0B" FontSize="24" FontWeight="Bold" Margin="0,1,0,6"/>
                <Border Background="#1C1C26" Height="1" Margin="0,0,0,8"/>
                <TextBlock Text="Removed" Foreground="#4B5563" FontSize="11"/>
                <TextBlock Text="this session" Foreground="#252535" FontSize="9" Margin="0,1,0,2"/>
                <TextBlock x:Name="TxtRemovedCount"   Text="0" Foreground="#22C55E" FontSize="24" FontWeight="Bold" Margin="0,1,0,0"/>
              </StackPanel>
            </Border>

            <Border Grid.Row="2" Background="#111118" CornerRadius="10" Padding="14,12" BorderBrush="#1E2E1E" BorderThickness="1">
              <StackPanel>
                <TextBlock Text="INFO" FontSize="10" FontWeight="Bold" Foreground="#374151" Margin="0,0,0,6"/>
                <TextBlock TextWrapping="Wrap" Foreground="#374151" FontSize="10" LineHeight="15">Removes phantom and unpresent old devices previously connected. Reduces IRQ overhead, lowers input latency and makes input smoother. Gains scale with devices removed. CPU affinity devices are always preserved.</TextBlock>
              </StackPanel>
            </Border>

          </Grid>
          <Grid Grid.Column="2">
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Grid Grid.Row="0" Margin="0,0,0,8">
              <TextBlock Text="DETECTED DEVICES" FontSize="10" FontWeight="Bold" Foreground="#374151" VerticalAlignment="Center"/>
              <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                <Button x:Name="BtnSelectAll"  Content="Select All" Style="{StaticResource GhostBtn}" Padding="11,5"/>
                <Button x:Name="BtnSelectNone" Content="None"       Style="{StaticResource GhostBtn}" Padding="11,5" Margin="6,0,0,0"/>
              </StackPanel>
            </Grid>

            <Border Grid.Row="1" Background="#111118" CornerRadius="10" BorderBrush="#1E1E2E" BorderThickness="1">
              <Grid>
                <ScrollViewer x:Name="EmptyState" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Padding="2,0,6,0">
                  <StackPanel MaxWidth="480" HorizontalAlignment="Center" Margin="16,14,16,14">
                    <StackPanel HorizontalAlignment="Center" Margin="0,0,0,12">
                      <TextBlock Text="[ ]" FontSize="26" Foreground="#1C1C2E" HorizontalAlignment="Center"
                                 FontFamily="Consolas" Margin="0,0,0,8"/>
                      <TextBlock Text="Ghost Device Remover" Foreground="#4B5563" FontSize="14"
                                 FontWeight="SemiBold" HorizontalAlignment="Center"/>
                      <TextBlock Text="v1.0" Foreground="#252535" FontSize="10"
                                 HorizontalAlignment="Center" Margin="0,3,0,0"/>
                    </StackPanel>
                    <TextBlock TextWrapping="Wrap" Foreground="#374151" FontSize="11" LineHeight="17"
                               TextAlignment="Center" Margin="0,0,0,12">
                      Scans and removes phantom devices left behind by disconnected USB peripherals.
                      Improves system responsiveness, reduces driver conflicts and speeds up device initialization.
                      Ideal for competitive players and power users.
                    </TextBlock>
                    <Border Background="#1A1A28" Height="1" Margin="0,0,0,12"/>
                    <TextBlock Text="WHAT THIS TOOL DOES" FontSize="9" FontWeight="Bold" Foreground="#252535"
                               HorizontalAlignment="Center" Margin="0,0,0,8"/>
                    <StackPanel HorizontalAlignment="Left" Margin="12,4,0,0">
                      <StackPanel Orientation="Horizontal" Margin="0,0,0,5">
                        <Ellipse Width="4" Height="4" Fill="#3B82F6" Margin="0,5,8,0" VerticalAlignment="Top"/>
                        <TextBlock TextWrapping="Wrap" Foreground="#374151" FontSize="11" LineHeight="16">Scans Unknown devices (Error Code 45) - hardware no longer connected</TextBlock>
                      </StackPanel>
                      <StackPanel Orientation="Horizontal" Margin="0,0,0,5">
                        <Ellipse Width="4" Height="4" Fill="#3B82F6" Margin="0,5,8,0" VerticalAlignment="Top"/>
                        <TextBlock TextWrapping="Wrap" Foreground="#374151" FontSize="11" LineHeight="16">Preserves devices with CPU affinity configured (IRQ pinning)</TextBlock>
                      </StackPanel>
                      <StackPanel Orientation="Horizontal" Margin="0,0,0,5">
                        <Ellipse Width="4" Height="4" Fill="#3B82F6" Margin="0,5,8,0" VerticalAlignment="Top"/>
                        <TextBlock TextWrapping="Wrap" Foreground="#374151" FontSize="11" LineHeight="16">Removes ghost entries via pnputil.exe - the native Windows device manager</TextBlock>
                      </StackPanel>
                    </StackPanel>
                    <Border Background="#1A1A28" Height="1" Margin="0,10,0,12"/>
                    <TextBlock Text="BENEFITS" FontSize="9" FontWeight="Bold" Foreground="#252535"
                               HorizontalAlignment="Center" Margin="0,0,0,8"/>
                    <UniformGrid Columns="3" Margin="12,0,12,0">
                      <Border Background="#0D1520" BorderBrush="#1A2535" BorderThickness="1" CornerRadius="4" Padding="0,5" Margin="2,0,2,4">
                        <TextBlock Text="Lower input latency" Foreground="#374151" FontSize="10" HorizontalAlignment="Center"/>
                      </Border>
                      <Border Background="#0D1520" BorderBrush="#1A2535" BorderThickness="1" CornerRadius="4" Padding="0,5" Margin="2,0,2,4">
                        <TextBlock Text="No IRQ conflicts" Foreground="#374151" FontSize="10" HorizontalAlignment="Center"/>
                      </Border>
                      <Border Background="#0D1520" BorderBrush="#1A2535" BorderThickness="1" CornerRadius="4" Padding="0,5" Margin="2,0,2,4">
                        <TextBlock Text="Cleaner registry" Foreground="#374151" FontSize="10" HorizontalAlignment="Center"/>
                      </Border>
                      <Border Background="#0D1520" BorderBrush="#1A2535" BorderThickness="1" CornerRadius="4" Padding="0,5" Margin="2,0,2,4">
                        <TextBlock Text="Faster boot" Foreground="#374151" FontSize="10" HorizontalAlignment="Center"/>
                      </Border>
                      <Border Background="#0D1520" BorderBrush="#1A2535" BorderThickness="1" CornerRadius="4" Padding="0,5" Margin="2,0,2,4">
                        <TextBlock Text="Faster USB init" Foreground="#374151" FontSize="10" HorizontalAlignment="Center"/>
                      </Border>
                      <Border Background="#0D1520" BorderBrush="#1A2535" BorderThickness="1" CornerRadius="4" Padding="0,5" Margin="2,0,2,4">
                        <TextBlock Text="Competitive edge" Foreground="#374151" FontSize="10" HorizontalAlignment="Center"/>
                      </Border>
                    </UniformGrid>
                  </StackPanel>
                </ScrollViewer>
                <ScrollViewer x:Name="DeviceScroller" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Padding="2,2,8,2" Visibility="Collapsed">
                  <StackPanel x:Name="DeviceList" Margin="6"/>
                </ScrollViewer>
              </Grid>
            </Border>

            <Border Grid.Row="2" Background="#0D0D15" CornerRadius="8" BorderBrush="#1C1C26" BorderThickness="1" Margin="0,8,0,6" Height="46">
              <ScrollViewer x:Name="LogScroller" VerticalScrollBarVisibility="Auto" Padding="2">
                <TextBlock x:Name="LogOutput" TextWrapping="Wrap" FontFamily="Consolas" FontSize="11" Foreground="#374151" Padding="12,7" Text="// Press Scan System to begin"/>
              </ScrollViewer>
            </Border>
          </Grid>
        </Grid>
        <Border Grid.Row="2" Background="#0D0D15" CornerRadius="0,0,12,12" BorderBrush="#1E1E2E" BorderThickness="0,1,0,0">
          <Grid Margin="16,0">
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
              <Button x:Name="BtnScan"   Content="  Scan System  "     Style="{StaticResource PrimaryBtn}"/>
              <Button x:Name="BtnRemove" Content="  Remove Selected  " Style="{StaticResource DangerBtn}" IsEnabled="False" Margin="12,0,0,0"/>
              <Button x:Name="BtnClear"  Content="Clear"               Style="{StaticResource GhostBtn}"  IsEnabled="False" Margin="10,0,0,0"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
              <TextBlock Text="Device Cleanup v1.0" Foreground="#3B82F6" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
            </StackPanel>
          </Grid>
        </Border>

      </Grid>
    </Border>
    <Thumb x:Name="ThumbL"  Width="5"  HorizontalAlignment="Left"   VerticalAlignment="Stretch" Margin="0,16,0,16" Opacity="0" Cursor="SizeWE"/>
    <Thumb x:Name="ThumbR"  Width="5"  HorizontalAlignment="Right"  VerticalAlignment="Stretch" Margin="0,16,0,16" Opacity="0" Cursor="SizeWE"/>
    <Thumb x:Name="ThumbT"  Height="5" VerticalAlignment="Top"      HorizontalAlignment="Stretch" Margin="16,0,16,0" Opacity="0" Cursor="SizeNS"/>
    <Thumb x:Name="ThumbB"  Height="5" VerticalAlignment="Bottom"   HorizontalAlignment="Stretch" Margin="16,0,16,0" Opacity="0" Cursor="SizeNS"/>
    <Thumb x:Name="ThumbTL" Width="14" Height="14" HorizontalAlignment="Left"  VerticalAlignment="Top"    Opacity="0" Cursor="SizeNWSE"/>
    <Thumb x:Name="ThumbTR" Width="14" Height="14" HorizontalAlignment="Right" VerticalAlignment="Top"    Opacity="0" Cursor="SizeNESW"/>
    <Thumb x:Name="ThumbBL" Width="14" Height="14" HorizontalAlignment="Left"  VerticalAlignment="Bottom" Opacity="0" Cursor="SizeNESW"/>
    <Thumb x:Name="ThumbBR" Width="14" Height="14" HorizontalAlignment="Right" VerticalAlignment="Bottom" Opacity="0" Cursor="SizeNWSE"/>
    <Path Data="M 0 10 L 10 0 M 3 10 L 10 3 M 7 10 L 10 7"
          Stroke="#252530" StrokeThickness="1.2"
          HorizontalAlignment="Right" VerticalAlignment="Bottom"
          Margin="0,0,7,7" IsHitTestVisible="False"/>
  </Grid>
</Window>
'@

function Show-ConfirmDialog {
    param([string]$message, [string]$warning = '')
    $safeMsg = [System.Security.SecurityElement]::Escape($message)
    $warnXml = if ($warning) { '<TextBlock Text="' + [System.Security.SecurityElement]::Escape($warning) + '" TextWrapping="Wrap" Foreground="#F59E0B" FontSize="11" Margin="0,8,0,0"/>' } else { '' }
    $ns  = 'xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"'
    $tNo = '<Button.Template><ControlTemplate TargetType="Button"><Border x:Name="bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="1" CornerRadius="7"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="Background" Value="#252530"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>'
    $tYes= '<Button.Template><ControlTemplate TargetType="Button"><Border x:Name="bd" Background="{TemplateBinding Background}" CornerRadius="7"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="Background" Value="#22C55E"/></Trigger><Trigger Property="IsPressed" Value="True"><Setter TargetName="bd" Property="Background" Value="#15803D"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template>'
    $dx  = '<Window ' + $ns + ' Width="380" SizeToContent="Height" WindowStartupLocation="CenterOwner" Background="Transparent" WindowStyle="None" AllowsTransparency="True" ResizeMode="NoResize" ShowInTaskbar="False">'
    $dx += '<Border Padding="12" Background="#06060C" CornerRadius="14"><Border CornerRadius="10" Background="#111118" BorderBrush="#2D2D40" BorderThickness="1"><StackPanel Margin="22,18,22,18">'
    $dx += '<StackPanel Orientation="Horizontal" Margin="0,0,0,14"><Border Background="#1C1020" CornerRadius="6" Width="30" Height="30" Margin="0,0,12,0">'
    $dx += '<TextBlock Text="!" FontSize="15" FontWeight="Bold" Foreground="#EF4444" HorizontalAlignment="Center" VerticalAlignment="Center"/>'
    $dx += '</Border><TextBlock Text="Confirm Removal" FontSize="14" FontWeight="SemiBold" Foreground="#E8E8F0" VerticalAlignment="Center"/></StackPanel>'
    $dx += '<TextBlock Text="' + $safeMsg + '" TextWrapping="Wrap" Foreground="#9CA3AF" FontSize="12" LineHeight="18"/>'
    $dx += $warnXml
    $dx += '<StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,16,0,0">'
    $dx += '<Button x:Name="BtnNo"  Content="Cancel" Width="88" Height="34" FontSize="12" FontWeight="SemiBold" Foreground="#9CA3AF" Background="#1C1C26" BorderBrush="#252530" BorderThickness="1" Cursor="Hand" Margin="0,0,8,0">' + $tNo  + '</Button>'
    $dx += '<Button x:Name="BtnYes" Content="Remove" Width="88" Height="34" FontSize="12" FontWeight="SemiBold" Foreground="White"   Background="#16A34A" BorderThickness="0" Cursor="Hand">'                                      + $tYes + '</Button>'
    $dx += '</StackPanel></StackPanel></Border></Border></Window>'
    $dlg = Parse-Xaml $dx
    $dlg.Owner = $script:Win
    $script:ConfirmResult = $false
    $dlg.FindName('BtnYes').Add_Click({ $script:ConfirmResult = $true;  $dlg.Close() })
    $dlg.FindName('BtnNo').Add_Click({  $script:ConfirmResult = $false; $dlg.Close() })
    $dlg.Add_MouseLeftButtonDown({ param($s,$e); if ($e.Source -isnot [System.Windows.Controls.Button]) { $dlg.DragMove() } })
    $dlg.ShowDialog() | Out-Null
    return $script:ConfirmResult
}

$script:Win = Parse-Xaml $mainXaml

foreach ($n in @('BtnScan','BtnRemove','BtnClear','BtnSelectAll','BtnSelectNone','BtnClose','BtnMinimize',
                 'DeviceList','EmptyState','DeviceScroller','LogOutput','LogScroller','StatusDot',
                 'StatusLabel','ProgressBar','TxtGhostCount','TxtProtectedCount','TxtRemovedCount',
                 'GithubBtn','ThumbL','ThumbR','ThumbT','ThumbB','ThumbTL','ThumbTR','ThumbBL','ThumbBR')) {
    Set-Variable -Name "script:$n" -Value $script:Win.FindName($n)
}

$script:DevicesToRemove  = @()
$script:DevicesProtected = @()
$script:RemovedTotal     = 0
$script:CheckBoxes       = [System.Collections.Generic.List[object]]::new()
$script:ScanRunspace     = $null
$script:ScanPS           = $null
$script:ScanHandle       = $null
$script:PollTimer        = $null
$script:RescanTimer      = $null
$script:ScanPct          = 0.0

function Write-Log {
    param([string]$msg)
    $time = Get-Date -Format 'HH:mm:ss'
    $script:Win.Dispatcher.Invoke([action]{
        $script:LogOutput.Text += "`n[$time]  $msg"
        $script:LogScroller.ScrollToBottom()
    })
}

function Set-StatusUI {
    param([string]$text, [string]$color)
    $script:Win.Dispatcher.Invoke([action]{
        $script:StatusLabel.Text = $text
        $script:StatusDot.Fill   = [System.Windows.Media.BrushConverter]::new().ConvertFromString($color)
    })
}

function Set-ProgressUI {
    param([double]$pct)
    $script:Win.Dispatcher.Invoke([action]{
        $pw = $script:ProgressBar.Parent.ActualWidth
        if ($pw -gt 0) { $script:ProgressBar.Width = [Math]::Max(0, [Math]::Min($pw, $pw * $pct)) }
    })
}

function New-Brush { param([string]$hex); [System.Windows.Media.BrushConverter]::new().ConvertFromString($hex) }

function Add-DeviceRow {
    param($device, [bool]$isProtected)
    # Escape only for XAML text display — Tag and ToolTip use the raw InstanceId for exact matching
    $devName    = [System.Security.SecurityElement]::Escape($device.Name)
    $devIdRaw   = (([string]$device.InstanceId) -replace '[
	]','').Trim()
    $devIdXaml  = [System.Security.SecurityElement]::Escape($devIdRaw)

    if ($isProtected) {
        $rowBg = '#0E1118'; $rowBd = '#1A2030'; $dot = '#1E3A5F'
        $nameFg = '#6B7280'; $bbg = '#0A1628'; $bfg = '#3B82F6'; $btxt = 'AFFINITY CONFIGURED'
        $cbXaml = '<CheckBox IsChecked="False" VerticalAlignment="Center" Margin="0,0,6,0" Foreground="#374151"/>'
    } else {
        $rowBg = '#13111A'; $rowBd = '#221A2E'; $dot = '#3B82F6'
        $nameFg = '#D1D5DB'; $bbg = '#1A0F1F'; $bfg = '#A78BFA'; $btxt = 'GHOST'
        $cbXaml = '<CheckBox IsChecked="True" VerticalAlignment="Center" Margin="0,0,6,0" Foreground="#E8E8F0"/>'
    }

    $row = Parse-Xaml @"
<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        CornerRadius="3" Margin="0,0,0,1" Padding="7,2,7,2"
        Background="$rowBg" BorderBrush="$rowBd" BorderThickness="1">
  <Grid>
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/>
    </Grid.ColumnDefinitions>
    <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Grid.Column="0">
      $cbXaml
      <Ellipse Width="4" Height="4" Fill="$dot" Margin="0,0,6,0" VerticalAlignment="Center"/>
      <TextBlock Text="$devName" FontSize="11" Foreground="$nameFg" TextTrimming="CharacterEllipsis" VerticalAlignment="Center"/>
    </StackPanel>
    <Border Grid.Column="1" CornerRadius="2" Padding="5,1,5,1" VerticalAlignment="Center" Background="$bbg">
      <TextBlock Text="$btxt" FontSize="8" FontWeight="SemiBold" Foreground="$bfg"/>
    </Border>
  </Grid>
</Border>
"@

    $cb = $null
    $q = [System.Collections.Queue]::new(); $q.Enqueue($row)
    while ($q.Count -gt 0) {
        $el = $q.Dequeue()
        if ($el -is [System.Windows.Controls.CheckBox]) { $cb = $el; break }
        if ($el -is [System.Windows.Controls.Panel]) { foreach ($c in $el.Children) { $q.Enqueue($c) } }
        elseif ($el -is [System.Windows.Controls.Border] -and $el.Child) { $q.Enqueue($el.Child) }
    }
    if ($cb) {
        # Tag uses RAW InstanceId — no XML escaping — so matching in BtnRemove is exact
        $cb.Tag = if ($isProtected) { 'PROTECTED::' + $devIdRaw } else { $devIdRaw }
        $script:CheckBoxes.Add($cb)
    }
    $row.ToolTip = $devIdRaw
    [void]$script:DeviceList.Children.Add($row)
}

function Reset-UI {
    $script:DeviceList.Children.Clear()
    $script:CheckBoxes.Clear()
    $script:DevicesToRemove  = @()
    $script:DevicesProtected = @()
    $script:EmptyState.Visibility     = [System.Windows.Visibility]::Visible
    $script:DeviceScroller.Visibility = [System.Windows.Visibility]::Collapsed
    $script:TxtGhostCount.Text     = '-'
    $script:TxtProtectedCount.Text = '-'
    $script:BtnRemove.IsEnabled    = $false
    $script:BtnClear.IsEnabled     = $false
    Set-StatusUI 'Ready to scan' '#374151'
    Set-ProgressUI 0
}

$script:Win.Add_MouseLeftButtonDown({
    param($s,$e)
    if ($e.Source -isnot [System.Windows.Controls.Button]) { $script:Win.DragMove() }
})

$script:BtnClose.Add_Click({
    if ($script:PollTimer)    { $script:PollTimer.Stop() }
    if ($script:RescanTimer)  { $script:RescanTimer.Stop() }
    if ($script:ScanRunspace) { try { $script:ScanRunspace.Dispose() } catch {} }
    $script:Win.Close()
})

$script:BtnMinimize.Add_Click({ $script:Win.WindowState = [System.Windows.WindowState]::Minimized })

$script:GithubBtn.Add_MouseLeftButtonDown({ Start-Process 'https://github.com/insovs' })
$script:GithubBtn.Add_MouseEnter({ $script:GithubBtn.Background = New-Brush '#111D2E' })
$script:GithubBtn.Add_MouseLeave({ $script:GithubBtn.Background = New-Brush '#0D1520' })

$script:BtnSelectAll.Add_Click({
    foreach ($cb in $script:CheckBoxes) {
        if (-not ($cb.Tag -is [string] -and $cb.Tag.StartsWith('PROTECTED::'))) { $cb.IsChecked = $true }
    }
})

$script:BtnSelectNone.Add_Click({ foreach ($cb in $script:CheckBoxes) { $cb.IsChecked = $false } })

$script:BtnScan.Add_Click({
    $script:BtnScan.IsEnabled = $script:BtnRemove.IsEnabled = $script:BtnClear.IsEnabled = $false
    $script:DeviceList.Children.Clear()
    $script:CheckBoxes.Clear()
    $script:DevicesToRemove  = @()
    $script:DevicesProtected = @()
    $script:EmptyState.Visibility     = [System.Windows.Visibility]::Collapsed
    $script:DeviceScroller.Visibility = [System.Windows.Visibility]::Visible

    Set-StatusUI 'Scanning system...' '#3B82F6'
    Set-ProgressUI 0.08
    Write-Log 'Scanning...'

    $script:ScanRunspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $script:ScanRunspace.ApartmentState = [System.Threading.ApartmentState]::STA
    $script:ScanRunspace.ThreadOptions  = [System.Management.Automation.Runspaces.PSThreadOptions]::UseNewThread
    $script:ScanRunspace.Open()

    $script:ScanPS = [System.Management.Automation.PowerShell]::Create()
    $script:ScanPS.Runspace = $script:ScanRunspace

    [void]$script:ScanPS.AddScript({
        function Test-HasRealAffinity {
            param([string]$InstanceId)
            try {
                $afPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId\Device Parameters\Interrupt Management\Affinity Policy"
                if (Test-Path $afPath) {
                    $a = Get-ItemProperty -Path $afPath -ErrorAction SilentlyContinue
                    if ($null -ne $a.DevicePolicy -and $a.DevicePolicy -ge 3) { return $true }
                    if ($a.AssignmentSetOverride) {
                        foreach ($b in [byte[]]$a.AssignmentSetOverride) { if ($b -ne 0) { return $true } }
                    }
                }
                return $false
            } catch { return $false }
        }

        function Clean-Id { param([string]$id); return ($id -replace '[\r\n\t]','').Trim() }

        # Wrap each PnpDevice in a plain PSCustomObject with a guaranteed-clean InstanceId
        function Wrap-Dev { param($dev)
            [PSCustomObject]@{
                Name       = ([string]$dev.FriendlyName).Trim()
                InstanceId = Clean-Id ([string]$dev.InstanceId)
                Status     = [string]$dev.Status
            }
        }

        $allRaw    = @(Get-PnpDevice -PresentOnly:$false -ErrorAction SilentlyContinue)
        $allDevs   = $allRaw | ForEach-Object { Wrap-Dev $_ }

        $ghosts    = @($allDevs | Where-Object { $_.Status -eq 'Unknown' })

        $seenIds   = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $toRemove  = [System.Collections.ArrayList]::new()
        $protected = [System.Collections.ArrayList]::new()

        foreach ($dev in $ghosts) {
            [void]$seenIds.Add($dev.InstanceId)
            if (Test-HasRealAffinity -InstanceId $dev.InstanceId) { [void]$protected.Add($dev) }
            else { [void]$toRemove.Add($dev) }
        }

        foreach ($dev in $allDevs) {
            if ($seenIds.Contains($dev.InstanceId)) { continue }
            if (Test-HasRealAffinity -InstanceId $dev.InstanceId) {
                [void]$seenIds.Add($dev.InstanceId)
                [void]$protected.Add($dev)
            }
        }

        return [PSCustomObject]@{ ToRemove = @($toRemove); Protected = @($protected) }
    })

    $script:ScanHandle = $script:ScanPS.BeginInvoke()
    $script:ScanPct    = 0.08

    $script:PollTimer = New-Object System.Windows.Threading.DispatcherTimer
    $script:PollTimer.Interval = [TimeSpan]::FromMilliseconds(200)
    $script:PollTimer.Add_Tick({
        if ($script:ScanPct -lt 0.88) { $script:ScanPct += 0.04; Set-ProgressUI $script:ScanPct }

        if ($script:ScanHandle -and $script:ScanHandle.IsCompleted) {
            $script:PollTimer.Stop()
            $res = $null
            try { $res = $script:ScanPS.EndInvoke($script:ScanHandle) } catch {}
            try { $script:ScanPS.Dispose() }      catch {}
            try { $script:ScanRunspace.Dispose() } catch {}
            $script:ScanPS = $script:ScanRunspace = $script:ScanHandle = $null

            $scanResult = if ($res -and $res.Count -gt 0) { $res[0] } elseif ($res -and $res.ToRemove -ne $null) { $res } else { $null }
            if ($scanResult) {
                $script:DevicesToRemove  = @($scanResult.ToRemove  | Where-Object { $_ -ne $null })
                $script:DevicesProtected = @($scanResult.Protected | Where-Object { $_ -ne $null })

            } else {
                $script:DevicesToRemove  = @()
                $script:DevicesProtected = @()
                Write-Log 'No devices found.'
            }

            $script:Win.Dispatcher.Invoke([action]{
                $script:TxtGhostCount.Text     = $script:DevicesToRemove.Count.ToString()
                $script:TxtProtectedCount.Text = $script:DevicesProtected.Count.ToString()
                $ns = 'xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"'

                if ($script:DevicesToRemove.Count -gt 0) {
                    [void]$script:DeviceList.Children.Add((Parse-Xaml "<TextBlock $ns Text=""REMOVABLE GHOST DEVICES"" FontSize=""9"" FontWeight=""Bold"" Foreground=""#A78BFA"" Margin=""2,3,0,4""/>"))
                    foreach ($d in $script:DevicesToRemove) { Add-DeviceRow -device $d -isProtected $false }
                }

                if ($script:DevicesProtected.Count -gt 0) {
                    if ($script:DevicesToRemove.Count -gt 0) {
                        [void]$script:DeviceList.Children.Add((Parse-Xaml "<Border $ns Height=""1"" Background=""#1C1C26"" Margin=""0,5,0,5""/>"))
                    }
                    [void]$script:DeviceList.Children.Add((Parse-Xaml "<TextBlock $ns Text=""CPU AFFINITY PROTECTED"" FontSize=""9"" FontWeight=""Bold"" Foreground=""#3B82F6"" Margin=""2,0,0,4""/>"))
                    foreach ($d in $script:DevicesProtected) { Add-DeviceRow -device $d -isProtected $true }
                }

                if ($script:DevicesToRemove.Count -eq 0 -and $script:DevicesProtected.Count -eq 0) {
                    $script:EmptyState.Visibility     = [System.Windows.Visibility]::Visible
                    $script:DeviceScroller.Visibility = [System.Windows.Visibility]::Collapsed
                    Set-StatusUI 'System is clean' '#22C55E'
                    Write-Log 'System is clean.'
                } elseif ($script:DevicesToRemove.Count -eq 0) {
                    Set-StatusUI 'All devices protected' '#F59E0B'
                    Write-Log ('Protected: ' + $script:DevicesProtected.Count + ' - nothing to remove.')
                } else {
                    Set-StatusUI ('Ghost devices: ' + $script:DevicesToRemove.Count) '#EF4444'
                    Write-Log ('Ghosts: ' + $script:DevicesToRemove.Count + '   Protected: ' + $script:DevicesProtected.Count)
                    $script:BtnRemove.IsEnabled = $true
                }
                $script:BtnClear.IsEnabled = $script:BtnScan.IsEnabled = $true
            })
            Set-ProgressUI 1.0
        }
    })
    $script:PollTimer.Start()
})

$script:BtnRemove.Add_Click({
    $selected = [System.Collections.ArrayList]::new()
    foreach ($dev in $script:DevicesToRemove) {
        $id = (([string]$dev.InstanceId) -replace '[
	]','').Trim()
        foreach ($cb in $script:CheckBoxes) {
            if ([string]::Equals((([string]$cb.Tag) -replace '[
	]','').Trim(), $id, [StringComparison]::OrdinalIgnoreCase) -and $cb.IsChecked -eq $true) {
                [void]$selected.Add($dev); break
            }
        }
    }
    foreach ($dev in $script:DevicesProtected) {
        $id = 'PROTECTED::' + (([string]$dev.InstanceId) -replace '[
	]','').Trim()
        foreach ($cb in $script:CheckBoxes) {
            if ([string]::Equals((([string]$cb.Tag) -replace '[
	]','').Trim(), $id, [StringComparison]::OrdinalIgnoreCase) -and $cb.IsChecked -eq $true) {
                [void]$selected.Add($dev); break
            }
        }
    }

    if ($selected.Count -eq 0) { Write-Log 'No devices selected.'; return }

    $protCount = 0
    foreach ($dev in $script:DevicesProtected) {
        $id = 'PROTECTED::' + ([string]$dev.InstanceId).Trim()
        foreach ($cb in $script:CheckBoxes) {
            if ([string]::Equals(([string]$cb.Tag).Trim(), $id, [StringComparison]::OrdinalIgnoreCase) -and $cb.IsChecked -eq $true) {
                $protCount++; break
            }
        }
    }

    $warnLine = if ($protCount -gt 0) { "WARNING: $protCount protected device(s) included. This will remove your IRQ affinity configuration." } else { '' }
    if (-not (Show-ConfirmDialog -message ('Remove ' + $selected.Count + ' device(s)? This action cannot be undone.') -warning $warnLine)) {
        Write-Log 'Cancelled.'; return
    }

    $script:BtnRemove.IsEnabled = $script:BtnScan.IsEnabled = $false
    Set-StatusUI 'Removing devices...' '#EF4444'
    Write-Log ('Removing ' + $selected.Count + ' device(s)...')

    $ok = 0; $fail = 0

    foreach ($device in $selected) {
        $instanceId = ([string]$device.InstanceId).Trim()
        $devName    = ([string]$device.Name).Trim()
        $removed    = $false

        # Method 1: Remove-PnpDevice (native PS)
        try {
            Get-PnpDevice -InstanceId $instanceId -ErrorAction Stop | Remove-PnpDevice -Confirm:$false -ErrorAction Stop
            $removed = $true
        } catch {}

        # Method 2: pnputil /remove-device
        if (-not $removed) {
            try {
                & pnputil.exe /remove-device "$instanceId" 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) { $removed = $true }
            } catch {}
        }

        # Method 3: SetupAPI DiSetupDiRemoveDevice — bypasses PnP manager lock
        if (-not $removed) {
            try {
                $helperSrc = @'
using System;
using System.Runtime.InteropServices;

public class SetupApiRemove {
    [DllImport("setupapi.dll", SetLastError=true, CharSet=CharSet.Auto)]
    static extern IntPtr SetupDiGetClassDevsEx(ref Guid ClassGuid, string Enumerator, IntPtr hwndParent,
        uint Flags, IntPtr DeviceInfoSet, string MachineName, IntPtr Reserved);
    [DllImport("setupapi.dll", SetLastError=true, CharSet=CharSet.Auto)]
    static extern bool SetupDiEnumDeviceInfo(IntPtr DeviceInfoSet, uint MemberIndex, ref SP_DEVINFO_DATA DeviceInfoData);
    [DllImport("setupapi.dll", SetLastError=true, CharSet=CharSet.Auto)]
    static extern bool SetupDiGetDeviceInstanceId(IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData,
        System.Text.StringBuilder DeviceInstanceId, uint DeviceInstanceIdSize, out uint RequiredSize);
    [DllImport("setupapi.dll", SetLastError=true)]
    static extern bool SetupDiRemoveDevice(IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData);
    [DllImport("setupapi.dll", SetLastError=true)]
    static extern bool SetupDiDestroyDeviceInfoList(IntPtr DeviceInfoSet);

    [StructLayout(LayoutKind.Sequential)]
    struct SP_DEVINFO_DATA {
        public uint  cbSize;
        public Guid  ClassGuid;
        public uint  DevInst;
        public IntPtr Reserved;
    }

    const uint DIGCF_ALLCLASSES  = 0x04;
    const uint DIGCF_PRESENT     = 0x02;
    static readonly IntPtr INVALID_HANDLE = new IntPtr(-1);

    public static bool Remove(string instanceId) {
        Guid empty = Guid.Empty;
        // Scan ALL devices (present + non-present)
        IntPtr devs = SetupDiGetClassDevsEx(ref empty, null, IntPtr.Zero, DIGCF_ALLCLASSES, IntPtr.Zero, null, IntPtr.Zero);
        if (devs == INVALID_HANDLE) return false;
        try {
            SP_DEVINFO_DATA data = new SP_DEVINFO_DATA();
            data.cbSize = (uint)Marshal.SizeOf(data);
            for (uint i = 0; SetupDiEnumDeviceInfo(devs, i, ref data); i++) {
                var sb = new System.Text.StringBuilder(512);
                uint needed;
                if (!SetupDiGetDeviceInstanceId(devs, ref data, sb, (uint)sb.Capacity, out needed)) continue;
                if (string.Equals(sb.ToString(), instanceId, StringComparison.OrdinalIgnoreCase)) {
                    return SetupDiRemoveDevice(devs, ref data);
                }
            }
            return false;
        } finally { SetupDiDestroyDeviceInfoList(devs); }
    }
}
'@
                if (-not ([System.Management.Automation.PSTypeName]'SetupApiRemove').Type) {
                    Add-Type -TypeDefinition $helperSrc -Language CSharp -ErrorAction Stop
                }
                if ([SetupApiRemove]::Remove($instanceId)) { $removed = $true }
            } catch {}
        }

        # Method 4: reg.exe delete — brute-force registry removal with /f flag
        if (-not $removed) {
            try {
                $regKey = "HKLM\SYSTEM\CurrentControlSet\Enum\$instanceId"
                $out = & reg.exe delete "$regKey" /f 2>&1
                if ($LASTEXITCODE -eq 0) { $removed = $true }
            } catch {}
        }

        # Method 5: devcon.exe remove (if present on system or in script dir)
        if (-not $removed) {
            try {
                $devcon = Get-Command devcon.exe -ErrorAction SilentlyContinue |
                          Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue
                if (-not $devcon) {
                    $local = Join-Path $PSScriptRoot 'devcon.exe'
                    if (Test-Path $local) { $devcon = $local }
                }
                if ($devcon) {
                    & $devcon remove "@$instanceId" 2>&1 | Out-Null
                    if ($LASTEXITCODE -eq 0) { $removed = $true }
                }
            } catch {}
        }

        if ($removed) { $ok++ } else { $fail++ }
    }

    $script:RemovedTotal += $ok
    $script:TxtRemovedCount.Text = $script:RemovedTotal.ToString()
    Set-StatusUI 'Removal complete' '#22C55E'
    Write-Log ($ok.ToString() + ' removed' + $(if ($fail -gt 0) { ', ' + $fail + ' failed' } else { '' }) + '.')

    # Delay rescan by 2s so Windows PnP has time to settle device states after removal
    $script:RescanTimer = New-Object System.Windows.Threading.DispatcherTimer
    $script:RescanTimer.Interval = [TimeSpan]::FromMilliseconds(2000)
    $script:RescanTimer.Add_Tick({
        $script:RescanTimer.Stop()
        $script:RescanTimer = $null
        $script:BtnScan.IsEnabled = $true
        $script:BtnScan.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent))
    })
    $script:RescanTimer.Start()
})

$script:BtnClear.Add_Click({ Reset-UI; Write-Log 'Cleared.' })

function Resize-Win {
    param([double]$dw, [double]$dh, [bool]$fromLeft, [bool]$fromTop)
    $minW = $script:Win.MinWidth; $minH = $script:Win.MinHeight
    if ($fromLeft) {
        $newW = $script:Win.Width - $dw
        if ($newW -lt $minW) { $dw = $script:Win.Width - $minW; $newW = $minW }
        $script:Win.Left += $dw; $script:Win.Width = $newW
    } elseif ($dw -ne 0) { $script:Win.Width = [Math]::Max($minW, $script:Win.Width + $dw) }
    if ($fromTop) {
        $newH = $script:Win.Height - $dh
        if ($newH -lt $minH) { $dh = $script:Win.Height - $minH; $newH = $minH }
        $script:Win.Top += $dh; $script:Win.Height = $newH
    } elseif ($dh -ne 0) { $script:Win.Height = [Math]::Max($minH, $script:Win.Height + $dh) }
}

$script:ThumbR.Add_DragDelta({  param($s,$e); Resize-Win  $e.HorizontalChange 0                $false $false })
$script:ThumbL.Add_DragDelta({  param($s,$e); Resize-Win  $e.HorizontalChange 0                $true  $false })
$script:ThumbB.Add_DragDelta({  param($s,$e); Resize-Win  0 $e.VerticalChange                  $false $false })
$script:ThumbT.Add_DragDelta({  param($s,$e); Resize-Win  0 $e.VerticalChange                  $false $true  })
$script:ThumbBR.Add_DragDelta({ param($s,$e); Resize-Win  $e.HorizontalChange $e.VerticalChange $false $false })
$script:ThumbBL.Add_DragDelta({ param($s,$e); Resize-Win  $e.HorizontalChange $e.VerticalChange $true  $false })
$script:ThumbTR.Add_DragDelta({ param($s,$e); Resize-Win  $e.HorizontalChange $e.VerticalChange $false $true  })
$script:ThumbTL.Add_DragDelta({ param($s,$e); Resize-Win  $e.HorizontalChange $e.VerticalChange $true  $true  })

$script:Win.ShowDialog() | Out-Null

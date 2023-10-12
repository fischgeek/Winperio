namespace Winperio

open Avalonia.Controls
open Avalonia.FuncUI.DSL.Grid
open Avalonia.FuncUI.Builder

/// You can use modules in Avalonia.FuncUI in the same way you would do
/// in [Elmish ](https://elmish.github.io/elmish/)
module Main =
    open Elmish
    open Avalonia.FuncUI
    open Avalonia.FuncUI.Types
    open System.Diagnostics
    open System.Runtime.InteropServices
    open Avalonia.Controls
    open Avalonia.Layout
    open Avalonia.FuncUI.DSL


    type State =
        { noop: bool }

    type Links =
        | AvaloniaRepository
        | AvaloniaAwesome
        | FuncUIRepository
        | FuncUISamples

    type Msg = OpenUrl of Links

    let init = { noop = false }


    let update (msg: Msg) (state: State) =
        match msg with
        | OpenUrl link -> 
            let url = 
                match link with 
                | AvaloniaRepository -> "https://github.com/AvaloniaUI/Avalonia"
                | AvaloniaAwesome -> "https://github.com/AvaloniaCommunity/awesome-avalonia"
                | FuncUIRepository -> "https://github.com/fsprojects/Avalonia.FuncUI"
                | FuncUISamples -> "https://github.com/fsprojects/Avalonia.FuncUI/tree/master/src/Examples"
                 
            if RuntimeInformation.IsOSPlatform(OSPlatform.Windows) then
                let start = sprintf "/c start %s" url
                Process.Start(ProcessStartInfo("cmd", start)) |> ignore
            else if RuntimeInformation.IsOSPlatform(OSPlatform.Linux) then
                Process.Start("xdg-open", url) |> ignore
            else if RuntimeInformation.IsOSPlatform(OSPlatform.OSX) then
                Process.Start("open", url) |> ignore
            state

    let headerView (dock: Dock): IView = 
        StackPanel.create [
            StackPanel.dock dock
            StackPanel.verticalAlignment VerticalAlignment.Top
            StackPanel.children [
                TextBlock.create [
                    TextBlock.classes [ "title" ]
                    TextBlock.text "Thank you for using Avalonia.FuncUI"
                ]
                TextBlock.create [
                    TextBlock.classes [ "subtitle" ]
                    TextBlock.text (
                        "Avalonia.FuncUI is a project that provides you with an Elmish DSL for Avalonia Controls\n" + 
                        "for you to use in an F# idiomatic way. We hope you like the project and spread the word :)\n" +
                        "Questions ? Reach to us on Gitter, also check the links below"
                    )
                ]
            ]
        ] |> Helpers.generalize
        
        
    let avaloniaLinksView (dock: Dock) (dispatch: Msg -> unit) : IView = 
        StackPanel.create [
            StackPanel.dock dock
            StackPanel.horizontalAlignment HorizontalAlignment.Left
            StackPanel.children [
                TextBlock.create [
                    TextBlock.classes [ "title" ]
                    TextBlock.text "Avalonia"
                ]
                TextBlock.create [
                    TextBlock.classes [ "link" ]
                    TextBlock.onTapped(fun _ -> dispatch (OpenUrl AvaloniaRepository))
                    TextBlock.text "Avalonia Repository"
                ]
                TextBlock.create [
                    TextBlock.classes [ "link" ]
                    TextBlock.onTapped(fun _ -> dispatch (OpenUrl AvaloniaAwesome))
                    TextBlock.text "Awesome Avalonia"
                ]
            ]
        ] |> Helpers.generalize
        
    let avaloniaFuncUILinksView (dock: Dock) (dispatch: Msg -> unit) : IView = 
        StackPanel.create [
            StackPanel.dock dock
            StackPanel.horizontalAlignment HorizontalAlignment.Right
            StackPanel.children [
                TextBlock.create [
                    TextBlock.classes [ "title" ]
                    TextBlock.text "Avalonia.FuncUI"
                ]
                TextBlock.create [
                    TextBlock.classes [ "link" ]
                    TextBlock.onTapped(fun _ -> dispatch (OpenUrl FuncUIRepository))
                    TextBlock.text "Avalonia.FuncUI Repository"
                ]
                TextBlock.create [
                    TextBlock.classes [ "link" ]
                    TextBlock.onTapped(fun _ -> dispatch (OpenUrl FuncUISamples))
                    TextBlock.text "Samples"
                ] 
            ]
        ] |> Helpers.generalize
        
    //let dg = new Avalonia.Controls.DataGrid()
    //ivd.Outlet <- dg
    //let dgv = View.createWithOutlet()


    let cds = new ColumnDefinitions()
    let rds = new RowDefinitions()
    let cd1 = new ColumnDefinition()
    let cd2 = new ColumnDefinition()
    let rd1 = new RowDefinition()
    let rd2 = new RowDefinition()
    rd1.Height <- GridLength.Auto
    rd2.Height <- GridLength.Auto
    cd1.Width <- GridLength.Auto
    cd2.Width <- GridLength.Auto
    cds.Add(cd1)
    cds.Add(cd2)
    rds.Add(rd1)
    rds.Add(rd2)

    let createDG (attrs: IAttr<DataGrid> list): IView<DataGrid> =
        let v = ViewBuilder.Create<DataGrid>(attrs)
        v

    let view (state: State) (dispatch: Msg -> unit) =
        DockPanel.create [
            DockPanel.horizontalAlignment HorizontalAlignment.Center
            DockPanel.verticalAlignment VerticalAlignment.Top
            DockPanel.margin (0.0, 20.0, 0.0, 0.0)
            DockPanel.children [
                headerView Dock.Top
                avaloniaLinksView Dock.Left dispatch
                avaloniaFuncUILinksView Dock.Right dispatch

                //Control.init (fun _ -> ())

                Grid.create [
                    Grid.columnDefinitions cds
                    Grid.rowDefinitions rds
                    //Grid.rowDefinitions "2"
                    Grid.children [
                        TextBlock.create [
                            TextBlock.text "one"
                        ]
                    ]
                    Grid.children [
                        TextBlock.create [
                            TextBlock.text "two"
                        ]
                    ]
                ]
            ]
        ]
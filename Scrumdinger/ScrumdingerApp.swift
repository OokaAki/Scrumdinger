/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI

// アプリのエントリーポイントを定義(Swift 5.3以降)
@main
// Appプロトコルに準拠
// Appプロトコル：SwiftUIアプリケーションのエントリーポイント。
//これに準拠した構造体を定義することでアプリのライフサイクルを制御できる。
//mainアノテーションを使うことで実行可能になる。
struct ScrumdingerApp: App {
    // アプリ全体の状態を管理する
    // @StateObjectプロパティ：SwiftUIのビュー内でオブジェクトの状態を管理する。
//    オブジェクトをビューのライフサイクルと同じ期間に保持し、プロパティが変更された際の再生成を防ぐことができる。
    @StateObject private var store = ScrumStore()
    // @Stateプロパティ：ビューによって使用される値を管理する。値の変更が発生すると自動的にビューを再描画する。
//    Stateプロパティは、View内でしか使用できない。Stateプロパティは不変であるため、値を変更するためにはState構造体のwrappedValueプロパティを更新する必要がある。
    // State構造体のwrappedValueプロパティ：Stateプロパティラッパーによってラップされた値を取得または設定するためのプロパティ。$count.wrappedValue += 1などと使う
    @State private var errorWrapper: ErrorWrapper?

    // body：Scene型を返す必要がある
    // Scene型：表示するウィンドウやビューコントローラーの階層を定義。
    // Window：画面上でユーザーが操作できる単一の領域
    var body: some Scene {
        // 単一のウィンドウの階層を構築。複数のウィンドウを構築する場合は、WindowGroup構造体をネストする。
        WindowGroup {
            ScrumsView(scrums: $store.scrums) {
                // 非同期処理を扱うためのAPI
                Task {
                    do {
                        try await store.save(scrums: store.scrums)
                    } catch {
                        errorWrapper = ErrorWrapper(error: error,
                                                    guidance: "Try again later.")
                    }
                }
            }
            // Viewプロトコルの装飾子。SwiftUIが自動的に、非同期タスクの開始時にビューを更新し、タスクが完了したときにビューを再度更新することができる。
            .task {
                do {
                    try await store.load()
                } catch {
                    errorWrapper = ErrorWrapper(error: error,
                                                guidance: "Scrumdinger will load sample data and continue.")
                }
            }
            // 新しいビューを現在のビューの上にシートとして表示する。ローディングやダイアログ、エラーメッセージの表示などに便利。
//            表示するビューを第1引数に取り、表示された場合に呼び出すアクションを第2引数に取る。
//            オプションの3番目の引数を使用して、表示するビューに渡すデータを指定することもできる
            .sheet(item: $errorWrapper) {
                store.scrums = DailyScrum.sampleData
//                errorWrapperがnil以外の場合、.sheetはcontentパラメータに渡されたビューを表示する。
            } content: { wrapper in
                ErrorView(errorWrapper: wrapper)
            }
        }
    }
}

// プロパティラッパー：プロパティの振る舞いをカスタマイズするために使用される機能。

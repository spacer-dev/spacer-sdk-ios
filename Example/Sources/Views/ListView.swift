//
//  ListView.swift
//  Example
//
//  Created by Takehito Soi on 2021/06/21.
//

import SpacerSDK
import SwiftUI

struct ListView: View {
    private let spacerService = SpacerService()

    private let cbLockerService = SPR.cbLockerService()
    private let sprLockerService = SPR.sprLockerService()
    private let myLockerService = SPR.myLockerService()

    private let vStackSpacing: CGFloat = 10.0

    @State private var showingAlert: AlertItem?

    var body: some View {
        TabView {
            Group {
                ScrollView(.vertical) {
                    VStack(spacing: vStackSpacing) {
                        HeaderView(title: Strings.CBLockerService)
                        SimpleItemView(
                            title: Strings.CBLockerScanTitle, desc: Strings.CBLockerScanDesc, runnable: scan
                        )
                        InputItemView(
                            title: Strings.CBLockerPutTitle, desc: Strings.CBLockerPutDesc, textHint: Strings.CBLockerPutTextHint, runnable: put
                        )
                        InputItemView(
                            title: Strings.CBLockerTakeTitle, desc: Strings.CBLockerTakeDesc, textHint: Strings.CBLockerTakeTextHint, runnable: take
                        )
                        InputItemView(
                            title: Strings.CBLockerTakeWithKeyTitle, desc: Strings.CBLockerTakeWithKeyDesc, textHint: Strings.CBLockerTakeWithKeyTextHint, runnable: takeWithKey
                        )
                    }
                    .padding()
                }
            }
            .tabItem {
                Image(systemName: Strings.TabCBLockerIcon)
                Text(Strings.TabCBLockerName)
            }

            Group {
                ScrollView(.vertical) {
                    VStack(spacing: vStackSpacing) {
                        HeaderView(title: Strings.MyLockerService)
                        SimpleItemView(
                            title: Strings.MyLockerGetTitle, desc: Strings.MyLockerGetDesc, runnable: getMyLockers
                        )
                        InputItemView(
                            title: Strings.MyLockerReserveTitle, desc: Strings.MyLockerReserveDesc, textHint: Strings.MyLockerReserveTextHint, runnable: reserve
                        )
                        InputItemView(
                            title: Strings.MyLockerReserveCancelTitle, desc: Strings.MyLockerReserveCancelDesc, textHint: Strings.MyLockerReserveTextHint, runnable: reserveCancel
                        )
                        InputItemView(
                            title: Strings.MyLockerShareUrlKeyTitle, desc: Strings.MyLockerShareUrlKeyDesc, textHint: Strings.MyLockerShareUrlKeyTextHint, runnable: shareUrlKey
                        )
                    }
                    .padding()
                }
            }
            .tabItem {
                Image(systemName: Strings.TabMyLockerIcon)
                Text(Strings.TabMyLockerName)
            }

            Group {
                ScrollView(.vertical) {
                    VStack(spacing: vStackSpacing) {
                        HeaderView(title: Strings.SPRLockerService)
                        InputItemView(
                            title: Strings.SPRLockerGetTitle, desc: Strings.SPRLockerGetDesc, textHint: Strings.SPRLockerGetTextHint, runnable: getSPRLockers
                        )
                        InputItemView(
                            title: Strings.SPRUnitGetTitle, desc: Strings.SPRUnitGetDesc, textHint: Strings.SPRUnitGetTextHint, runnable: getSPRUnits
                        )
                    }
                    .padding()
                }
            }
            .tabItem {
                Image(systemName: Strings.TabSPRLockerIcon)
                Text(Strings.TabSPRLockerName)
            }
        }
        .alert(item: $showingAlert) { item in item.alert }
    }

    private func exec(success: @escaping (String) -> Void) {
        AppControl.shared.showLoading()

        spacerService.getToken(
            success: success,
            failure: failure
        )
    }

    private func failure(error: SPRError) {
        AppControl.shared.hideLoading()
        showingAlert = error.toAlertItem()
    }

    private func failure(error: ExampleError) {
        AppControl.shared.hideLoading()
        showingAlert = error.toAlertItem()
    }

    private func scan() {
        AppControl.shared.showLoading()

        exec { token in
            cbLockerService.scan(
                token: token,
                success: { sprLockers in
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.CBLockerScanSuccess(sprLockers)
                },
                failure: failure
            )
        }
    }

    private func put(spacerId: String) {
        AppControl.shared.showLoading()

        exec { token in
            cbLockerService.put(
                token: token,
                spacerId: spacerId,
                success: {
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.CBLockerPutSuccess(spacerId)
                },
                failure: failure
            )
        }
    }

    private func take(spacerId: String) {
        AppControl.shared.showLoading()

        exec { token in
            cbLockerService.take(
                token: token,
                spacerId: spacerId,
                success: {
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.CBLockerTakeSuccess(spacerId)
                },
                failure: failure
            )
        }
    }

    private func takeWithKey(urlKey: String) {
        AppControl.shared.showLoading()

        exec { token in
            cbLockerService.take(
                token: token,
                urlKey: urlKey,
                success: {
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.CBLockerTakeWithKeySuccess(urlKey)
                },
                failure: failure
            )
        }
    }

    private func getMyLockers() {
        AppControl.shared.showLoading()

        exec { token in
            myLockerService.get(
                token: token,
                success: { myLockers in
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.MyLockerGetSuccess(myLockers)
                },
                failure: failure
            )
        }
    }

    private func reserve(spacerId: String) {
        AppControl.shared.showLoading()

        exec { token in
            myLockerService.reserve(
                token: token,
                spacerId: spacerId,
                success: { myLocker in
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.MyLockerReserveSuccess(spacerId, myLocker)
                },
                failure: failure
            )
        }
    }

    private func reserveCancel(spacerId: String) {
        AppControl.shared.showLoading()

        exec { token in
            myLockerService.reserveCancel(
                token: token,
                spacerId: spacerId,
                success: {
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.MyLockerReserveCancelSuccess(spacerId)
                },
                failure: failure
            )
        }
    }

    private func shared(urlKey: String) {
        AppControl.shared.showLoading()

        exec { token in
            myLockerService.shareUrlKey(
                token: token,
                urlKey: urlKey,
                success: { myLocker in
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.MyLockerShareUrlKeySuccess(urlKey, myLocker)
                },
                failure: failure
            )
        }
    }

    private func getSPRLockers(spacerIdsText: String) {
        let spacerIds = spacerIdsText.components(separatedBy: ",")

        AppControl.shared.showLoading()

        exec { token in
            sprLockerService.get(
                token: token,
                spacerIds: spacerIds,
                success: { sprLockers in
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.SPRLockerGetSuccess(sprLockers)
                },
                failure: failure
            )
        }
    }

    private func getSPRUnits(unitIdsText: String) {
        let unitIds = unitIdsText.components(separatedBy: ",")

        AppControl.shared.showLoading()

        exec { token in
            sprLockerService.get(
                token: token,
                unitIds: unitIds,
                success: { sprUnits in
                    AppControl.shared.hideLoading()
                    showingAlert = AlertItem.SPRUnitGetSuccess(sprUnits)
                },
                failure: failure
            )
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}

//
//  EditIssueScreen.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 25/11/2024.
//

import SwiftUI

internal struct EditIssueScreen: View {
    
    @ObservedObject var viewModel: EditIssueViewModel
    
    init(viewModel: EditIssueViewModel) {
        FontLoader.load()
        self.viewModel = viewModel
    }
    
    var body: some View {
        
//        if let build = viewModel.build {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(viewModel.issueTitle)
                            .font(.deliver(ofSize: 20, weight: .black))
                            .padding(.bottom, 24)
                        Spacer()
                    }
                    build()
                    editor()
                    //technical()
                    media()
                }
                .padding(24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("New issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { viewModel.close()  }) {
                        Text("Close")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.postIssue() }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 26, height: 26)
                            .padding(.trailing, 8)
                    }
                }
            }
//        }
//        else {
//            VStack(alignment: .leading) {
//                
//                HStack {
//                    Spacer()
//                    Image(systemName: "xmark.circle")
//                        .resizable()
//                        .frame(width: 52, height: 52)
//                        .foregroundColor(Color(.dRed))
//                    Spacer()
//                }
//                .padding(.bottom, 16)
//                    Text("We are not able to find the build information.\nIssue reporting and live debug are disabled.")
//                        .font(.system(size: 16, weight: .bold))
//                        .padding(.bottom, 8)
//                    Text("Please check if your app key is valid and if you have correctly  specify CFBundleVersion")
//                
//                HStack(spacing: 0) {
//                    Text("AppKey: ")
//                        .fontWeight(.bold)
//                    Text(Deliver.key.isEmpty ? "Invalid" : Deliver.key)
//                        
//                }
//                .padding(.top, 16)
//                
//                HStack(spacing: 0) {
//                    Text("CFBundleVersion: ")
//                        .fontWeight(.bold)
//                    Text(Deliver.buildNumber ?? "Invalid")
//                    
//                }
//            }
//            .padding()
//        }
    }
    
    @ViewBuilder
    func build() -> some View {
        if let build = viewModel.build {
            VStack(alignment: .leading) {
                Text("Build information")
                    .font(.deliver(ofSize: 16, weight: .bold))
                    .padding(.top, 24)
                
                HeaderView(build: build)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(16)
            }
        }
        else { EmptyView() }
    }
    
    
    
    func editor() -> some View {
        VStack(alignment: .leading) {
            Text("Issue")
                .font(.deliver(ofSize: 16, weight: .bold))
            //                        .padding([.leading, .trailing], 24)
                .padding(.top, 24)
            
            VStack(alignment: .leading) {
                Group {
                    Text("Issue title")
                        .font(.deliver(ofSize: 14, weight: .bold))
                    SwiftUI.TextField("", text: $viewModel.issueTitle)
                        .font(.deliver(ofSize: 14, weight: .medium))
                    Divider()
                    //                        TextField(value: /*$viewModel.issueTitle*/, placeHolder: "••••••", label: "Issue title")
                    
                    Text("Description")
                        .font(.deliver(ofSize: 14, weight: .bold))
                        .padding(.top, 16)
                    TextEditor(text: $viewModel.description)
                }
                .padding([.horizontal], 8)
            }
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    func technical() -> some View {
        VStack(alignment: .leading) {
            Text("Technical data")
                .font(.deliver(ofSize: 16, weight: .bold))
                .padding(.top, 24)
            VStack(alignment: .leading) {
                Group {
                    HStack(spacing: 2) {
                        Toggle("", isOn: $viewModel.attachNetwork)
                        Text("Attach network traffic")
                        //                        Image(systemName: "cloud")
                    }
                    .onTapGesture {
                        viewModel.attachNetwork.toggle()
                    }
                    HStack(spacing: 2) {
                        Toggle("", isOn: $viewModel.attachLogs)
                        Text("Attach application logs")
                    }
                    .onTapGesture {
                        viewModel.attachLogs.toggle()
                    }
                }
                .toggleStyle(CheckboxToggleStyle())
                .font(.deliver(ofSize: 16, weight: .semibold))
                .padding([.leading, .top], 8)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    @ViewBuilder
    func media() -> some View {
        VStack(alignment: .leading) {
            Text("Attachments")
                .font(.deliver(ofSize: 16, weight: .bold))
            
                .padding(.top, 24)
            VStack(alignment: .leading) {
                if let mediaURL = viewModel.media, // Assuming media is an optional URL
                   let data = try? Data(contentsOf: mediaURL),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit() // Optional: Adjust display style
                        .frame(width: 100)
                        .cornerRadius(5)
                        .padding(8)
                        .background(Color(.dLightGray).opacity(0.5))
                        .cornerRadius(5)
                        .onTapGesture {
                            
                        }
                } else {
                    Text("No screenshot or video record")
                        .font(.deliver(ofSize: 16, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
            .padding([.horizontal], 8)
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

private struct HeaderView: View {
    
    var build: Build
    
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy: HH:mm"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(build.version)
                                .lineLimit(1)
                                .font(.deliver(ofSize: 14, weight: .bold))
                            
                        }
                        Text(formatDate(build.createdAt))
                            .font(.deliver(ofSize: 12, weight: .regular))
                    }
                    Spacer()
                    status()
//                    Button(action: { installHandler?() }) {
//                        HStack {
//                            Image(systemName: "icloud.and.arrow.down")
//                                .resizable()
//                                .frame(width: 16, height: 16)
//                            Text("Install")
//                                .font(.deliver(ofSize: 12, weight: .bold))
//                        }
//                        .foregroundColor(Color.white)
//                    }
//                    .padding(6)
//                    .padding(.horizontal, 6)
//                    .background(Color.blue)
//                    .cornerRadius(4)
                }
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("Publisher")
                            .font(.deliver(ofSize: 12, weight: .medium))
                        UserAvatar(user: Context.shared.user, size: 24)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pipeline")
                            .font(.deliver(ofSize: 12, weight: .medium))
                        Text(build.pipelineId)
                            .font(.code(ofSize: 12))
                            .foregroundColor(Color.black)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.dGray).opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(.dGray).opacity(0.3), lineWidth: 1)
                            )
                    }
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Commit hash")
                            .font(.deliver(ofSize: 12, weight: .medium))
                        Text(build.commitHash)
                            .font(.code(ofSize: 12))
                            .foregroundColor(Color.black)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.dGray).opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(.dGray).opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Issue")
                        .font(.deliver(ofSize: 12, weight: .semibold))
                    Text(build.customerIssue)
                        .font(.deliver(ofSize: 14, weight: .regular))
                    
                }
                HStack(spacing: 0) {
                    Text("Branch: ")
                        .font(.deliver(ofSize: 12, weight: .semibold))
                    Text(build.branch)
                        .font(.code(ofSize: 12))
                }
                
                VStack(alignment: .leading) {
                    Text("Commit message")
                        .font(.deliver(ofSize: 12, weight: .semibold))
                    Text(build.commitMessage ?? "-")
                        .font(.deliver(ofSize: 14, weight: .regular))
                }
                
            }
            .padding([.leading], 8)
            Spacer()
        }
    }
    
    
    func color() -> Color {
        var color = Color.blue
        if let status = build.status {
            switch status {
                case "OK": color = .green
                case "KO": color = .red
                case "TEST_IN_PROGRESS" : color = .orange
                default: color = Color.blue
            }
        }
        return color
    }
    
    @ViewBuilder
    func status() -> some View {
        
        if let status = build.status {
            Text(status == "TEST_IN_PROGRESS" ? "TESTING" : status.uppercased() )
                .font(.deliver(ofSize: 12, weight: .bold))
                .foregroundColor(color().opacity(0.8))
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color().opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(color().opacity(0.5), lineWidth: 1)
                )
        }
        else {
            EmptyView()
        }
    }
    
}


struct EditIssueScreenPreview: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            EditIssueScreen(viewModel: EditIssueViewModel(media: URL(string: "http://localhost:3000/api/img/1.png")!))
        }
    }
}

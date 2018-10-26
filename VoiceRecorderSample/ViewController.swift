

import UIKit
import AVFoundation

// tableViewのdelegate,datasourceに加えて、AVAudioRecorder（録音に使うプロトコル）、AVAudioPlayer(再生に使うプロトコル)のdelegateを宣言
class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource{
    
    // それぞれのパーツを宣言
    @IBOutlet var label: UILabel!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var playButton: UIButton!
    
    // 音声録音、再生するプロトコルのインスタンスを宣言
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    // 現在が録音状態か，再生状態かを判別するbool型の変数も宣言
    var isRecording = false
    var isPlaying = false
    
    // 録音名を入れる配列
    var records: [String] = []
    // 現在の録音番号を表す
    var number  = 0
    // 現在選んでいるセルの番号を入れる
    var selectedRow: Int!
    
    // 録音するためのセッティングを設定する(ここは理解しなくて良い)
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // tableViewのdelegate,datasourceの処理をviewControllerに依頼する
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        // ボタンの設定
        playButton.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
        playButton.layer.borderWidth = 1
        playButton.isEnabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // セルの数を決めるメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    // セルの内容を決めるメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        // 録音名を表示させる
        cell?.textLabel?.text = records[indexPath.row]
        cell?.tag = indexPath.row
        return cell!
    }
    
    // セルを選択した時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        playButton.isEnabled = true
    }
    
    // 録音する
    @IBAction func record(){
        // isRecordingがfalseの時（=録音中ではない時）
        if !isRecording{
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try! session.setActive(true)
            
            // URLの場所に保存（数字からURLを生成するメソッドを呼び出す）
            audioRecorder = try! AVAudioRecorder(url: getUrl(recordingNum: self.number), settings: settings)
            audioRecorder.delegate = self
            // 記録開始
            audioRecorder.record()
            
            isRecording = true
            label.text = "録音中"
            // 録音したらボタンの文字を"Stop"にする
            recordButton.setTitle("STOP", for: .normal)
            //playButton.isEnabled = false
            
        } else {
            // isRecordingがtrueの時（=録音中の時）
            //記録終了
            audioRecorder.stop()
            isRecording = false
            
            label.text = "待機中"
            recordButton.setTitle("RECORD", for: .normal)
            
            // 保存する際にアラートを呼ぶ
            let alert = UIAlertController(title: "保存", message: "録音を保存いたしますか？", preferredStyle: .alert)
            // アラートにtextFieldを追加する
            alert.addTextField { (textField) in
                textField.placeholder = "録音名を追加してください"
                textField.text = "録音\(self.number + 1)"
            }
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                let textFields = alert.textFields
                
                for text in textFields! {
                    self.records.append(text.text!)
                }

                // tableViewを更新する（cellForRowAtを呼び出す）
                self.tableView.reloadData()
                self.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            number += 1
        }
    }
    
    func getUrl(recordingNum: Int) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let url = docsDirect.appendingPathComponent(String(recordingNum))
        return url
    }
    
    
    @IBAction func play() {
        if !isPlaying {
            audioPlayer = try! AVAudioPlayer(contentsOf: getUrl(recordingNum: selectedRow))
            print(getUrl(recordingNum: selectedRow))
            audioPlayer.delegate = self
            audioPlayer.play()
            
            isPlaying = true
            
            label.text = "再生中"
            playButton.setTitle("STOP", for: .normal)
            recordButton.isEnabled = false
            
        }else{
            
            audioPlayer.stop()
            isPlaying = false
            
            label.text = "待機中"
            playButton.setTitle("PLAY", for: .normal)
            recordButton.isEnabled = true
            
        }
    }
    

}


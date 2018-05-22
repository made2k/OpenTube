import UIKit

class AppSettingsViewController: UITableViewController {
  
  @IBOutlet weak var streamQualityLabel: UILabel!
  @IBOutlet weak var downloadQualityLabel: UILabel!
  @IBOutlet weak var fetchIntervalLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }
  
  @IBAction func dismissButtonPressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  private func configureView() {
    switch Settings.defaultStreamQuality {
    case .high:
      streamQualityLabel.text = "High (720p)"
    case .medium:
      streamQualityLabel.text = "Medium (360p)"
    case .small:
      streamQualityLabel.text = "Low (260p)"
    }
    
    switch Settings.defaultDownloadQuality {
    case .high:
      downloadQualityLabel.text = "High (720p)"
    case .medium:
      downloadQualityLabel.text = "Medium (360p)"
    case .small:
      downloadQualityLabel.text = "Low (260p)"
    }
    
    let fetchMinutes = Int(Settings.backgroudFetchInterval / 60.0)
    fetchIntervalLabel.text = "\(fetchMinutes)m"
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      if indexPath.row == 0 {
        showQualityPicker { quality in
          Settings.defaultStreamQuality = quality
          self.configureView()
        }
      } else if indexPath.row == 1 {
        showQualityPicker { quality in
          Settings.defaultDownloadQuality = quality
          self.configureView()
        }
      }
    }
    
    if indexPath.section == 1 {
      showTimePicker { interval in
        Settings.backgroudFetchInterval = interval
        UIApplication.shared.setMinimumBackgroundFetchInterval(interval)
        self.configureView()
      }
    }
  }
  
  private func showQualityPicker(selection: @escaping (VideoQuality) -> Void) {
    
    let alert = UIAlertController(title: "Video Quality", message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "High (720p)", style: .default) { _ in
      selection(.high)
    })
    alert.addAction(UIAlertAction(title: "Medium (360p)", style: .default) { _ in
      selection(.medium)
    })
    alert.addAction(UIAlertAction(title: "Low (260p)", style: .default) { _ in
      selection(.small)
    })
    
    present(alert, animated: true, completion: nil)
    
  }
  
  private func showTimePicker(completion: @escaping (TimeInterval) -> Void) {
    let alert = UIAlertController(title: "Fetch Interval", message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "1 Hour", style: .default) { _ in
      completion( 60 * 60 )
    })
    alert.addAction(UIAlertAction(title: "30 Minutes", style: .default) { _ in
      completion( 30 * 60 )
    })
    alert.addAction(UIAlertAction(title: "15 Minutes", style: .default) { _ in
      completion( 15 * 60 )
    })
    
    present(alert, animated: true, completion: nil)
  }
}

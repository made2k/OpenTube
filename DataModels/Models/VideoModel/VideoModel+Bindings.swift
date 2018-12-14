
import RxSwift

/*
 Extension to handle bindings related to the VideoModel
 */
extension VideoModel {

  private var watchedThreshold: Double {
    return 0.95
  }
  private var progressThreshold: Double {
    return 0.01
  }

  func setupBindings() {

    // When progress greater then threshold, the video is considered watched
    watchProgress.asObservable()
      .map { [unowned self] in $0 > self.watchedThreshold }
      .bind(to: isWatched)
      .disposed(by: disposeBag)

    // When progress is started and not watched, video is in progress
    watchProgress.asObservable()
      .map { [unowned self] in $0 >= self.progressThreshold && $0 < self.watchedThreshold }
      .bind(to: inProgress)
      .disposed(by: disposeBag)

    // Save the watch progress to DB
    watchProgress.asObservable()
      .throttle(1, scheduler: MainScheduler.asyncInstance)
      .distinctUntilChanged()
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] progress in
        self.persisted.updateProgress(progress)
      }).disposed(by: disposeBag)

    // Save the duration meta data to DB
    duration.asObservable()
      .distinctUntilChanged()
      .filterNil()
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] duration in
        self.persisted.updateDuration(duration)
      }).disposed(by: disposeBag)

    // Update duration description label
    duration.asObservable()
      .map { [unowned self] in self.durationString(for: $0) }
      .bind(to: durationDescription)
      .disposed(by: disposeBag)

    // Save hidden to DB
    hidden.asObservable()
      .distinctUntilChanged()
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] hidden in
        self.persisted.updateHidden(hidden)
      }).disposed(by: disposeBag)

    // Save last watched to DB
    lastWatchedDate.asObservable()
      .distinctUntilChanged()
      .observeOn(MainScheduler.asyncInstance)
      .subscribe(onNext: { [unowned self] watchDate in
        self.persisted.updateLastWatched(watchDate)
      }).disposed(by: disposeBag)
  }

  // MARK: - Other

  private func durationString(for duration: TimeInterval?) -> String? {
    guard let duration = duration else { return nil }

    let hours = Int(duration / 3600)
    let minutes = Int(duration.truncatingRemainder(dividingBy: 3600) / 60)
    let seconds = Int(duration.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))

    let hourString = hours > 0 ? "\(String(format: "%02d", hours)):" : ""

    return "\(hourString)\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
  }
  
}

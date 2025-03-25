#!/usr/bin/env bb

(require '[babashka.fs :as fs])
(require '[clojure.string :as str])

(def version-file "./version")

;; 1. Check if version file exists
(when-not (fs/exists? version-file)
  (println (str "Error: version file not found at " version-file))
  (System/exit 1))

;; 2. Read current version
(def version (str/trim (slurp version-file)))

;; 3. Validate version format (x.y.z)
(when-not (re-matches #"\d+\.\d+\.\d+" version)
  (println (str "Error: Invalid version format in " version-file ". Expected x.y.z"))
  (System/exit 1))

;; 4. Split version into components
(let [[major minor patch] (map #(Integer/parseInt %)
                               (str/split version #"\."))]
  
  ;; 5. Check arguments
  (when-not (= 1 (count *command-line-args*))
    (println (str "Usage: " (fs/file-name (System/getProperty "babashka.file")) " [major|minor|patch]"))
    (System/exit 1))
  
  ;; 6. Bump the appropriate component
  (let [arg (first *command-line-args*)
        [new-major new-minor new-patch]
        (case arg
          "major" [(inc major) 0 0]
          "minor" [major (inc minor) 0]
          "patch" [major minor (inc patch)]
          (do
            (println "Error: Invalid argument. Use major, minor, or patch")
            (System/exit 1)))]
    
    ;; 7. Construct and write new version
    (let [new-version (str new-major "." new-minor "." new-patch)]
      (spit version-file new-version)
      (println (str "Version bumped to " new-version)))))

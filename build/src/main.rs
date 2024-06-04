use pulsectl::controllers::SinkController;
use pulsectl::controllers::DeviceControl;

fn main() {
    println!("Hello, world!");

    
// create handler that calls functions on playback devices and apps
let mut handler = SinkController::create().unwrap();

let devices = handler
    .list_devices()
    .expect("Could not get list of playback devices.");
    
println!("Playback Devices: ");
for dev in devices.clone() {
    println!(
        "[{}] {}, Volume: {}",
        dev.index,
        dev.description.as_ref().unwrap(),
        dev.volume.print()
    );
}
}

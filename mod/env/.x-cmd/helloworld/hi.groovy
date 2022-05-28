@RestController
class HelloController {
    @RequestMapping("/home")
    String home() {
        "Hello World!"
    }
}
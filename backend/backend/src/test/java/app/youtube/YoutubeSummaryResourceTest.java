package app.youtube;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.empty;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.containsString;

@QuarkusTest
class YoutubeSummaryResourceTest {
    @Test
    void testGetSummariesInitiallyEmpty() {
        given()
          .when().get("/summary")
          .then()
             .statusCode(200)
             .body("", empty());
    }

    @Test
    void testCreateAndGetSummary() {
        String youtubeUrl = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";
        // POST a new summary
        given()
            .contentType("application/json")
            .body("{\"youtubeUrl\": \"" + youtubeUrl + "\"}")
            .when().post("/summary")
            .then()
            .statusCode(200)
            .body("id", notNullValue())
            .body("youtubeUrl", is(youtubeUrl))
            .body("summary", containsString("simulated transcript"));
        // GET should now return at least one summary
        given()
          .when().get("/summary")
          .then()
             .statusCode(200)
             .body("", hasSize(1));
    }
}
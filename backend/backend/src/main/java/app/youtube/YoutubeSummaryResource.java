package app.youtube;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Column;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Optional;
import jakarta.json.Json;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import java.io.StringReader;
import java.io.IOException;
import java.net.http.HttpRequest.BodyPublishers;
import java.util.logging.Logger;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@Entity
@Table(name = "summaries")
class Summary {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(name = "youtube_url", nullable = false)
    public String youtubeUrl;

    @Column(name = "summary", nullable = false)
    public String summary;

    @Column(name = "created_at")
    public java.sql.Timestamp createdAt;
}

interface SummaryRepository {
    void persist(Summary summary);
    List<Summary> listAll();
}

@jakarta.enterprise.context.ApplicationScoped
class SummaryRepositoryImpl implements SummaryRepository {
    @Inject
    EntityManager em;

    @Transactional
    public void persist(Summary summary) {
        em.persist(summary);
    }

    public List<Summary> listAll() {
        return em.createQuery("SELECT s FROM Summary s ORDER BY s.createdAt DESC", Summary.class).getResultList();
    }
}

@ApplicationScoped
class YoutubeSummaryService {
    private static final Logger LOGGER = Logger.getLogger(YoutubeSummaryService.class.getName());
    private static final String OPENAI_API_KEY = System.getenv("OPENAI_API_KEY");
    private static final String OPENAI_API_URL = Optional.ofNullable(System.getenv("OPENAI_API_URL")).orElse("https://api.openai.com/v1/chat/completions");
    private static final HttpClient httpClient = HttpClient.newHttpClient();

    @ConfigProperty(name = "transcript.service.url")
    String transcriptServiceUrl;

    public String generateSummary(String youtubeUrl) {
        try {
            String transcript = fetchYoutubeTranscript(youtubeUrl);
            if (transcript == null || transcript.isEmpty()) {
                return "No transcript available for this video.";
            }
            String summary = callOpenAISummarizer(transcript);
            return summary;
        } catch (Exception e) {
            LOGGER.warning("Error generating summary: " + e.getMessage());
            return "Error generating summary: " + e.getMessage();
        }
    }

    private String fetchYoutubeTranscript(String youtubeUrl) throws IOException, InterruptedException {
        // Call the Python microservice
        String requestBody = "{\"youtubeUrl\": \"" + youtubeUrl + "\"}";
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(transcriptServiceUrl))
                .header("Content-Type", "application/json")
                .POST(BodyPublishers.ofString(requestBody))
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            throw new RuntimeException("Transcript service error: " + response.body());
        }
        try (JsonReader jsonReader = Json.createReader(new StringReader(response.body()))) {
            JsonObject jsonObject = jsonReader.readObject();
            if (jsonObject.containsKey("transcript")) {
                return jsonObject.getString("transcript");
            } else if (jsonObject.containsKey("error")) {
                throw new RuntimeException("Transcript error: " + jsonObject.getString("error"));
            } else {
                throw new RuntimeException("Unexpected transcript service response");
            }
        }
    }

    private String callOpenAISummarizer(String transcript) throws Exception {
        if (OPENAI_API_KEY == null || OPENAI_API_KEY.isEmpty()) {
            throw new IllegalStateException("OpenAI API key is not set in environment variables.");
        }
        String prompt = "Summarize the following YouTube transcript in a concise paragraph:\n" + transcript;
        String requestBody = "{" +
                "\"model\": \"gpt-3.5-turbo\"," +
                "\"messages\": [{\"role\": \"user\", \"content\": " + Json.createObjectBuilder().add("content", prompt).build().getString("content") + "}]," +
                "\"max_tokens\": 200" +
                "}";
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(OPENAI_API_URL))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + OPENAI_API_KEY)
                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            throw new RuntimeException("OpenAI API error: " + response.body());
        }
        // Parse the response JSON to extract the summary
        try (JsonReader jsonReader = Json.createReader(new StringReader(response.body()))) {
            JsonObject jsonObject = jsonReader.readObject();
            String summary = jsonObject
                .getJsonArray("choices")
                .getJsonObject(0)
                .getJsonObject("message")
                .getString("content");
            return summary;
        }
    }
}

@Path("/summary")
public class YoutubeSummaryResource {
    @Inject
    SummaryRepository summaryRepository;
    @Inject
    YoutubeSummaryService summaryService;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public List<Summary> getSummaries() {
        return summaryRepository.listAll();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @Transactional
    public Response createSummary(YoutubeUrlRequest request) {
        Summary summary = new Summary();
        summary.youtubeUrl = request.youtubeUrl;
        summary.summary = summaryService.generateSummary(request.youtubeUrl);
        summary.createdAt = new java.sql.Timestamp(System.currentTimeMillis());
        summaryRepository.persist(summary);
        return Response.ok(summary).build();
    }

    public static class YoutubeUrlRequest {
        public String youtubeUrl;
    }
}

package com.example.integratedgrp.event;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class EventApiIntegrationTest {
    @Autowired
    private MockMvc mockMvc;

    @Test
    void createsEventAcceptsApplicationAndListsApplicants() throws Exception {
        String eventResponse = mockMvc.perform(post("/api/events")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"name":"Build Night","duration":"2 days","description":"A weekend hackathon"}
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("Build Night"))
                .andReturn()
                .getResponse()
                .getContentAsString();
        long eventId = com.fasterxml.jackson.databind.json.JsonMapper.builder()
                .build()
                .readTree(eventResponse)
                .get("id")
                .asLong();

        mockMvc.perform(get("/api/events"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value("Build Night"));

        mockMvc.perform(post("/api/events/{eventId}/applications", eventId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"applicantName":"Riley Chen","reason":"I want to build an accessibility tool."}
                                """))
                .andExpect(status().isCreated());

        mockMvc.perform(get("/api/events/{eventId}/applications", eventId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].applicantName").value("Riley Chen"));

        mockMvc.perform(post("/api/events/{eventId}/applications", eventId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"applicantName":"riley chen","reason":"A duplicate application."}
                                """))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ALREADY_APPLIED"));
    }

    @Test
    void rejectsBlankEventFields() throws Exception {
        mockMvc.perform(post("/api/events")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"name":" ","duration":"1 day","description":"An event"}
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_REQUEST"));
    }
}
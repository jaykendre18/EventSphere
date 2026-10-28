package com.example.integratedgrp.event;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(
        name = "event_applications",
        uniqueConstraints = @UniqueConstraint(columnNames = {"event_id", "applicant_name"}))
public class EventApplicationEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "event_id", nullable = false)
    private EventEntity event;

    @Column(name = "applicant_name", nullable = false, length = 120)
    private String applicantName;

    @Column(nullable = false, length = 2000)
    private String reason;

    @Column(nullable = false, updatable = false)
    private Instant appliedAt;

    protected EventApplicationEntity() {}

    public EventApplicationEntity(EventEntity event, String applicantName, String reason) {
        this.event = event;
        this.applicantName = applicantName;
        this.reason = reason;
        this.appliedAt = Instant.now();
    }

    public Long getId() {
        return id;
    }

    public EventEntity getEvent() {
        return event;
    }

    public String getApplicantName() {
        return applicantName;
    }

    public String getReason() {
        return reason;
    }

    public Instant getAppliedAt() {
        return appliedAt;
    }
}